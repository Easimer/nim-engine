# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import os
import sdl2, sdl2/gfx
import gl
import winmgr

var exit = false

proc sighandler() {.noconv.} =
    exit = true

proc main() =
    setControlCHook(sighandler)

    let wnd = openWindow(640, 480)
    defer: closeWindow(wnd)
  

    gl.load_functions(glGetProcAddress)
    gl.clearColor(0.392, 0.584, 0.929, 1.0)
    gl.viewport(0, 0, 640, 480)

    while not exit:
        exit = processEvents(wnd)
        gl.clear(GL_COLOR_BUFFER_BIT)
        swapWindow(wnd)

main()
