# Package

version       = "0.1.0"
author        = "Daniel Meszaros"
description   = "Nim Engine"
license       = "GPL-2.0"
srcDir        = "src"
bin           = @["nim_engine"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0"
requires "sdl2 >= 2.0.1"
requires "stbimage >= 2.3"
