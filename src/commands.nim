# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import macros
import strutils
import tables

var cmdTable: Table[string, proc()]

proc defineCommand*(cmd: string, fn: proc()) =
    cmdTable.add(cmd, fn)

proc execCommand*(cmd: string) =
    cmdTable[cmd]()