# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import os
import sdl2, sdl2/gfx
import gl
import winmgr

var exit = false

proc sighandler() {.noconv.} =
    exit = true

type ShaderProgram = object
    shader_vertex: GLshaderID
    shader_fragment: GLshaderID
    program: GLprogramID

proc destroy(shader: ShaderProgram) =
    gl.deleteProgram(shader.program)
    # Shaders constituing this program are automatically freed by the driver

proc loadShaderProgramFromFile(path_vertex: string, path_fragment: string): ShaderProgram =
    var file_vertex, file_fragment: File
    defer: file_vertex.close()
    defer: file_fragment.close()
    if file_vertex.open(path_vertex) and file_fragment.open(path_fragment):
        result.shader_vertex = gl.createShader(GL_VERTEX_SHADER)
        result.shader_fragment = gl.createShader(GL_FRAGMENT_SHADER)
        let src_vertex = cast[string](file_vertex.readAll())
        let src_fragment = cast[string](file_fragment.readAll())
        var src_vertex_len : GLint = len(src_vertex)
        var src_fragment_len : Glint = len(src_fragment)
        result.shader_vertex.shaderSource(1, src_vertex, addr src_vertex_len)
        result.shader_fragment.shaderSource(1, src_fragment, addr src_fragment_len)
        result.program = gl.createProgram()
        result.program.attachShader(result.shader_vertex)
        result.program.attachShader(result.shader_fragment)
        result.program.linkProgram()
    
proc useProgram(p: ShaderProgram) =
    gl.useProgram(p.program)

proc main() =
    setControlCHook(sighandler)

    let wnd = openWindow(640, 480)
    defer: closeWindow(wnd)
  

    gl.load_functions(glGetProcAddress)
    gl.clearColor(0.392, 0.584, 0.929, 1.0)
    gl.viewport(0, 0, 640, 480)

    let prog = loadShaderProgramFromFile("core/shaders/test_vrtx.glsl", "core/shaders/test_frag.glsl")
    defer: destroy(prog)

    # Hello Triangle
    let vertices: array[9, GLfloat] = [
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    ]

    var buffers: array[1, GLVBO]

    gl.genBuffers(1, addr buffers)

    while not exit:
        exit = processEvents(wnd)
        gl.clear(GL_COLOR_BUFFER_BIT)
        swapWindow(wnd)

    

main()
