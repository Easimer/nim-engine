# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import macros

const
  GL_DEPTH_BUFFER_BIT*        = 0x00000100
  GL_STENCIL_BUFFER_BIT*      = 0x00000400
  GL_COLOR_BUFFER_BIT*        = 0x00004000
  GL_FALSE*                   = 0
  GL_TRUE*                    = 1

type
  GLbitfield = uint32
  GLfloat = float32

type
  PFNGETPROCADDR = (proc(name: cstring): pointer {.cdecl.})

proc addProcTypedef(proctypeSection : NimNode, name: string; procty: NimNode) =
  expectKind(procty, nnkProcTy)

  proctypeSection.add(nnkTypeDef.newTree(
      newIdentNode(name),
      newEmptyNode(),
      procty
    )
  )

proc addFuncptr(funcptr_list: NimNode, procname: string, proctypename: string) =
  expectKind(funcptr_list, nnkStmtList)

  funcptr_list.add(
    nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        postfix(newIdentNode(procname), "*"),
        newIdentNode(proctypename),
        newEmptyNode()
      )
    )
  )

proc addLoadStatement(loading_statements: NimNode, procname: string, proctypename: string, sym: string) =
  expectKind(loading_statements, nnkStmtList)

  loading_statements.add(
    nnkAsgn.newTree(
      newIdentNode(procname),
      nnkCast.newTree(
        newIdentNode(proctypename),
        nnkCall.newTree(
          newIdentNode("loader"),
          newLit(sym)
        )
      )
    )
  )

macro loadGLAPI(api_entries: untyped): untyped =
  result = newStmtList()

  # Contains the function pointer typedefs
  let proctype_section = nnkTypeSection.newTree()
  # Lists the function pointer entries
  let funcptr_list = nnkStmtList.newTree()
  # Contains the procedure loading statements of load_functions()
  let loading_statements = nnkStmtList.newTree()
  # Build procedure load_functions
  let load_functions_proc = nnkProcDef.newTree(
    nnkPostfix.newTree(
      newIdentNode("*"),
      newIdentNode("load_functions")
    ),
    newEmptyNode(),
    newEmptyNode(),
    nnkFormalParams.newTree(
      newEmptyNode(),
      nnkIdentDefs.newTree(
        newIdentNode("loader"),
        newIdentNode("PFNGETPROCADDR"),
        newEmptyNode()
      )
    ),
    newEmptyNode(),
    newEmptyNode(),
    loading_statements
  )

  for api in api_entries:
    let sym = $api[0]
    let procname = $api[1]
    let proctype = api[2]
    let proctypename = procname & "_t"

    proctype_section.addProcTypedef(proctypename, proctype)
    funcptr_list.addFuncptr(procname, proctypename)
    loading_statements.addLoadStatement(procname, proctypename, sym)
  
  result.add proctype_section
  result.add funcptr_list
  result.add load_functions_proc

# (C symbol name, Nim procedure name, Procedure type)
loadGLAPI:
  ("glClear", "clear",
    proc(mask: GLbitfield) {.cdecl.})
  ("glClearColor", "clearColor",
    proc(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) {.cdecl.})
  ("glViewport", "viewport",
    proc(x: int, y: int, w: int, h: int) {.cdecl.})