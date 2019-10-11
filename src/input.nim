# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import tables

type input_system = object
    bindings: Table[int, string]

proc bindKey(inpsys: input_system, key: int, command: string) =
    inpsys.bindings[key] = command

proc processKeyPress(inpsys: input_system, key: int) =
    if key in inpsys.bindings:
        var a = "asd"
        # TODO: Fire command
    
proc processKeyRelease(inpsys: input_system, key: int) =
    if key in inpsys.bindings:
        var a = "TODO"
        # TODO: Fire command
