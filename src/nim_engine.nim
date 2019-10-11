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

    # Hello Triangle
    let vertices: array[9, GLfloat] = [
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    ]

    var buffers: array[1, GLuint]

    gl.genBuffers(1, addr buffers)

    while not exit:
        exit = processEvents(wnd)
        gl.clear(GL_COLOR_BUFFER_BIT)
        swapWindow(wnd)

main()
