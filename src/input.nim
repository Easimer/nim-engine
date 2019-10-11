# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import tables
import commands

type input_system* = object
    bindings: Table[int, string]

proc bindKey*(inpsys: var input_system, key: int, command: string) =
    inpsys.bindings.add(key, command)

proc processKeyPress*(inpsys: var input_system, key: int) =
    if key in inpsys.bindings:
        let cmd = inpsys.bindings[key]
        execCommand(cmd)
    
proc processKeyRelease*(inpsys: var input_system, key: int) =
    if key in inpsys.bindings:
        let cmd = inpsys.bindings[key]
        case cmd[0]:
            of '+':
                var cmdinv = cmd
                cmdinv[0] = '-'
                execCommand(cmdinv)
            else:
                execCommand(cmd)


