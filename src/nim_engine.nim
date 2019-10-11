# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import os
import sdl2
import gl

var exit = false

proc sighandler() {.noconv.} =
  exit = true

proc main() =
  setControlCHook(sighandler)

  gl.load_functions(sdl2.gl_loader)
  gl.clearColor(0.392, 0.584, 0.929, 1.0)

  while not exit:
    gl.clear(gl.GL_COLOR_BUFFER_BIT)
    sdl2.swap_buffers(window)

main()
