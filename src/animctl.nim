# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import strutils
import macros
import tables
import gfx
import sequtils
import draw_info # sprite_id

type Transition = object
    condition: NimNode
    fromState: string
    toState: string
    immediately: bool

type Trigger* = object
    value: bool

type BaseAnimationController* = ref object of RootObj

converter triggerToBool*(t: var Trigger): bool =
    result = t.value
    t.value = false

converter boolToTrigger*(v: bool): Trigger =
    result.value = v

proc parseOptArgument(t: var Transition, arg: string) =
    case arg:
        of "Immediately":
            t.immediately = true
        else:
            error "Unknown optional argument provided: '" & arg & "'!"

proc parseTransition(transition: NimNode): Transition =
    let transType = $transition[0]
    var cmd = transition
    if transType == "JumpIf":
        if len(cmd) < 2: # no cond
            error "Conditional transition declaration on line " & lineInfo(transition) & " is missing a condition!"
        else:
            result.condition = cmd[1][0]
            cmd = cmd[1][1]
    
    let tokenFrom = cmd[0]
    if $tokenFrom != "From":
        error "Transition action should start with 'From'!"
    cmd = cmd[1]

    result.fromState = $cmd[0]
    cmd = cmd[1]

    let tokenTo = cmd[0]

    if $tokenTo != "To":
        error "In a transition the fromState should be followed by a 'To' keyword!"
    
    cmd = cmd[1]
    case kind(cmd):
        of nnkIdent: # No optional arguments
            result.toState = $cmd
            cmd = nil
        of nnkCommand:
            result.toState = $cmd[0]
            cmd = cmd[1]
        else:
            error "Unexpected expression on line " & lineInfo(cmd) & "!"
    
    while cmd != nil:
        case kind(cmd):
            of nnkIdent: # No more arguments
                result.parseOptArgument($cmd)
                cmd = nil
            of nnkCommand:
                result.parseOptArgument($cmd[0])
                cmd = cmd[1]
            else:
                error "Unexpected expression on line " & lineInfo(cmd) & "!"

proc generateStateEnum(animctlName: string, states: seq[string]): NimNode =
    var enumTy = nnkEnumTy.newTree(
        newEmptyNode(),
    )

    for state in states:
        enumTy.add(newIdentNode(state))

    result = nnkTypeDef.newTree(
        nnkPragmaExpr.newTree(
            newIdentNode(animctlName & "State"),
            nnkPragma.newTree(
                newIdentNode("pure")
            )
        ),
        newEmptyNode(),
        enumTy,
    )

proc generateObject(animctlName: string, vars: seq[tuple[ident: string, vtype: NimNode]]): NimNode =
    var recList = nnkRecList.newTree(
        nnkIdentDefs.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                newIdentNode("currentState"),
            ), newIdentNode(animctlName & "State"), newEmptyNode(),
        ),
        nnkIdentDefs.newTree(
            newIdentNode("sprites"), nnkBracketExpr.newTree(
                newIdentNode("Table"),
                newIdentNode(animctlName & "State"),
                newIdentNode("sprite_id")
            ),
            newEmptyNode(),
        ),
        nnkIdentDefs.newTree(
            newIdentNode("sprite"), newIdentNode("sprite_id"), newEmptyNode(),
        )
    )

    for acvar in vars:
        recList.add nnkIdentDefs.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                newIdentNode(acvar[0])
            ), acvar[1][0], newEmptyNode(),
        )

    result = nnkTypeDef.newTree(
        nnkPostfix.newTree(
            newIdentNode("*"),
            newIdentNode(animctlName),
        ),
        newEmptyNode(),
        nnkRefTy.newTree(
            nnkObjectTy.newTree(
                newEmptyNode(),
                nnkOfInherit.newTree(
                    newIdentNode("BaseAnimationController")
                ),
                recList,
            )
        )
    )

proc generateTypedefs(animctlName: string, states: seq[string], vars: seq[tuple[ident: string, vtype: NimNode]]): NimNode =
    var nodeTypeSection = nnkTypeSection.newTree()
    nodeTypeSection.add(generateStateEnum(animctlName, states))
    nodeTypeSection.add(generateObject(animctlName, vars))

proc generateInit(animctlName: string, startState: string, anims: Table[string, string]): NimNode =
    let animctlTy = newIdentNode(animctlName)
    let enumId = newIdentNode(animctlName & "State")
    let defStateId = newIdentNode(startState)
    let animctlInstanceName = genSym(nskParam, "animctl")
    var spriteLoads = newStmtList()

    for anim in anims.pairs:
        let animName = newIdentNode(anim[0])
        let animPath = newStrLitNode(anim[1])
        spriteLoads.add:
            quote do:
                `animctlInstanceName`.sprites[`enumId`.`animName`] = gGfx.load_sprite(`animPath`)

    result = quote do:
        method init*(`animctlInstanceName.strVal`: var `animctlTy`) {.base.} =
            `animctlInstanceName`.currentState = `enumId`.`defStateId`
            `spriteLoads`

proc replaceEveryIdent(expression: NimNode, id: string, replacement: NimNode): NimNode =
    result = expression.kind.newTree()
    for i in 0 .. len(expression) - 1:
        var child = expression[i]
        if child.kind == nnkIdent:
            if $child == id:
                result.add(replacement)
            else:
                result.add(child)
        else:
            result.add(replaceEveryIdent(child, id, replacement))
            

proc generateStateTransition(animctlName: string, transitions: seq[Transition]): NimNode =
    let animctlTy = newIdentNode(animctlName)
    let enumId = newIdentNode(animctlName & "State")
    let animctlInstanceName = genSym(nskParam, "ctl")

    var transMap = initTable[string, seq[Transition]]()

    for transition in transitions:
        if not (transition.fromState in transMap):
            transMap[transition.fromState] = @[]
        transMap[transition.fromState].add(transition)
    
    var switch = nnkCaseStmt.newTree(
        nnkDotExpr.newTree(animctlInstanceName, newIdentNode("currentState")),
        nnkElse.newTree(
            newStmtList(
                nnkDiscardStmt.newTree(
                    newNilLit()
                )
            )
        )
    )

    for mapping in transMap.pairs:
        var iftree = newStmtList()

        var branchings = nnkIfStmt.newTree()

        for transition in mapping[1]:
            let newStateIdent = newIdentNode(transition.toState)
            # Replace every ident("ctl") in condition to animctlInstanceName
            branchings.add:
                nnkElifExpr.newTree(
                    replaceEveryIdent(transition.condition, "ctl", animctlInstanceName),
                    quote do:
                        `animctlInstanceName`.currentState = `enumId`.`newStateIdent`
                )

        iftree.add(branchings)   

        switch.add nnkOfBranch.newTree(
            nnkDotExpr.newTree(enumId, newIdentNode(mapping[0])),
            iftree,
        )
    
    result = quote do:
        method stateTransition*(`animctlInstanceName`: var `animctlTy`, dt: float) =
            `switch`

macro setupAnimationController*(typeName: string, decl: untyped): untyped =
    var ctlStates: seq[string]
    var ctlVariables: seq[tuple[ident: string, vtype: NimNode]]
    var ctlTransitions: seq[Transition]
    var ctlStartState: string
    var ctlAnimations: Table[string, string]

    # Parse the animctl declaration
    expectKind(decl, nnkStmtList)
    for section in decl:
        expectKind(section, nnkCall)
        let sectionName = toLower($section[0])
        case sectionName:
            of "states":
                if len(section) > 1:
                    for state in section[1]:
                        expectKind(state, nnkIdent)
                        let stateID = $state
                        ctlStates.add(stateID)
                else:
                    warning "Animation controller '" & $typeName & "' has no states declared!"
            of "variables":
                if len(section) > 1:
                    for vardecl in section[1]:
                        expectKind(vardecl, nnkCall)
                        expectKind(vardecl[0], nnkIdent)
                        expectKind(vardecl[1], nnkStmtList)
                        let ident = $vardecl[0]
                        let vtype = vardecl[1]
                        ctlVariables.add((ident, vtype))
            of "transitions":
                if len(section) > 1:
                    for transition in section[1]:
                        case $transition[0]:
                            of "JumpIf":
                                expectKind(transition, nnkCommand)
                                ctlTransitions.add(parseTransition(transition))
                            of "Jump":
                                expectKind(transition, nnkCommand)
                                ctlTransitions.add(parseTransition(transition))
                            of "Start":
                                expectKind(transition, nnkCommand)
                                ctlStartState = $transition[1]
                            else: error "Unknown transition type '" & $transition[0] & "'!"
            of "animations":
                if len(section) > 1:
                    for mapping in section[1]:
                        expectKind(mapping, nnkInfix)
                        if $mapping[0] == "->":
                            expectKind(mapping[1], nnkIdent)
                            expectKind(mapping[2], nnkStrLit)
                            ctlAnimations[mapping[1].strVal] = mapping[2].strVal
                        else:
                            error "Expected operator -> in state:animation mapping on line " & lineInfo(mapping) & ", got " & $mapping[0] & "!"
                else:
                    warning "No animations declared on line " & lineInfo(section) & "!"
            else:
                error "Unknown section '" & sectionName & "'!"
    echo("============\nAnimation controller '" & typeName.strVal() & "'")
    echo("States:")
    for state in ctlStates:
        echo(state)
    echo("\nVariables:")
    for variable in ctlVariables:
        echo(variable.ident)
    echo("\nTransitions:")
    for transition in ctlTransitions:
        echo((transition.fromState, transition.toState))
    echo("\nAnimations")
    for mapping in ctlAnimations.pairs:
        echo(mapping)
    
    result = newStmtList()
    result.add(generateTypedefs(typeName.strVal, ctlStates, ctlVariables))
    result.add(generateInit(typename.strVal, ctlStartState, ctlAnimations))
    result.add(generateStateTransition(typename.strVal, ctlTransitions))

method stateTransition*(animctl: var BaseAnimationController, dt: float) {.base.} = discard nil

#[
setupAnimationController("AnimControllerPlayer"):
    states:
        Idle
        RunningLeft
        RunningRight
        Jumping
        Aiming
        Shooting
    variables:
        isRunning: bool
        runDirection: bool
        midAir: bool
        aiming: bool
        shoot: Trigger
    transitions:
        Start Idle
        JumpIf (ctl.isRunning and ctl.runDirection == true) From Idle To RunningRight
        JumpIf (ctl.isRunning and ctl.runDirection == false) From Idle To RunningLeft
        JumpIf (not ctl.isRunning) From RunningLeft To Idle Immediately
        JumpIf (not ctl.isRunning) From RunningRight To Idle Immediately
    animations:
        Idle -> "data/player/idle.aseprite"
        RunningLeft -> "data/player/running_left.aseprite"
        RunningRight -> "data/player/running_right.aseprite"
        Jumping -> "data/player/jumping.aseprite"
        Aiming -> "data/player/aiming.aseprite"
        Shooting -> "data/player/shooting.aseprite"
]#

type
    AnimControllerPlayerState {.pure.} = enum
      Idle, RunningLeft, RunningRight, Jumping, Aiming, Shooting
    AnimControllerPlayer* = ref object of BaseAnimationController
      currentState*: AnimControllerPlayerState
      sprites: Table[AnimControllerPlayerState, sprite_id]
      sprite: sprite_id
      isRunning*: bool
      runDirection*: bool
      midAir*: bool
      aiming*: bool
      shoot*: Trigger
  
method init*(animctl_343000: var AnimControllerPlayer) {.base.} =
    animctl_343000.currentState = Idle
  
method stateTransition*(ctl_343028: var AnimControllerPlayer; dt: float) =
    case ctl_343028.currentState:
        of AnimControllerPlayerState.RunningRight:
            if not ctl_343028.isRunning:
                ctl_343028.currentState = Idle
        of AnimControllerPlayerState.Idle:
            if ctl_343028.isRunning and ctl_343028.runDirection == true:
                ctl_343028.currentState = RunningRight
            elif ctl_343028.isRunning and ctl_343028.runDirection == false: ctl_343028.currentState = RunningLeft
        of AnimControllerPlayerState.RunningLeft:
            if not ctl_343028.isRunning:
                ctl_343028.currentState = Idle  
        else:
            discard nil

proc getSprite*[AnimCtlT](animctl: AnimCtlT): sprite_id = animctl.sprite