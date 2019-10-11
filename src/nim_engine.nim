# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import os
import sdl2, sdl2/gfx
import gl
import winmgr
import input
import commands
import vector
import matrix

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
        let csrc_vertex : cstring = src_vertex
        let csrc_fragment : cstring = src_fragment
        let pcsrc_vtx : ptr cstring = csrc_vertex.unsafeAddr
        let pcsrc_frag : ptr cstring = csrc_fragment.unsafeAddr
        result.shader_vertex.shaderSource(1, pcsrc_vtx, nil)
        result.shader_fragment.shaderSource(1, pcsrc_frag, nil)
        result.shader_vertex.compileShader()
        result.shader_fragment.compileShader()
        result.program = gl.createProgram()
        result.program.attachShader(result.shader_vertex)
        result.program.attachShader(result.shader_fragment)
        result.program.linkProgram()

        var status : array[1, GLint]
        result.program.getProgram(GL_LINK_STATUS, status)
        assert(status[0] > 0)
    else:
        echo "Failed to load shaders " & path_vertex & " and/or " & path_fragment
    
proc useProgram(p: ShaderProgram) =
    gl.useProgram(p.program)

proc debugCallback(source: GLenum, msgtype: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: cstring, userParam: pointer) {.cdecl.} =
    echo "OpenGL: " & $message

type player = object
    pos: vec4
    vel: vec4
    acc: vec4

proc update(p: var player, dt: float) =
    p.vel += dt * p.acc
    p.pos += dt * p.vel

    # Simulate friction
    p.vel *= 1 - 0.2 * dt

    zeroCheck(p.acc)
    zeroCheck(p.vel)

var localplayer: player

defineCommand("+forward"):
    localplayer.acc.y = 8

defineCommand("-forward"):
    localplayer.acc.y = 0

defineCommand("+lstrafe"):
    localplayer.acc.x = -8

defineCommand("-lstrafe"):
    localplayer.acc.x = 0

defineCommand("+rstrafe"):
    localplayer.acc.x = 8

defineCommand("-rstrafe"):
    localplayer.acc.x = 0


defineCommand("+back"):
    localplayer.acc.y = -8

defineCommand("-back"):
    localplayer.acc.y = 0

proc main() =
    var inpsys: input_system
    setControlCHook(sighandler)

    inpsys.bindKey(K_w, "+forward")
    inpsys.bindKey(K_a, "+lstrafe")
    inpsys.bindKey(K_s, "+back")
    inpsys.bindKey(K_d, "+rstrafe")

    let wnd = openWindow(640, 480)
    defer: closeWindow(wnd)

    gl.load_functions(glGetProcAddress)
    gl.enable(GL_DEBUG_OUTPUT)
    gl.debugMessageCallback(debugCallback, nil)
    gl.clearColor(0.392, 0.584, 0.929, 1.0)
    gl.viewport(0, 0, 640, 480)

    let prog = loadShaderProgramFromFile("core/shaders/test.vrtx.glsl", "core/shaders/test.frag.glsl")
    defer: destroy(prog)

    # Hello Triangle
    var vertices: array[9, GLfloat] = [
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    ]

    var buffers: array[1, GLVBO]
    var arrays: array[1, GLVAO]

    gl.genVertexArrays(1, addr arrays)
    gl.bindVertexArray(arrays[0])

    gl.genBuffers(1, addr buffers)
    gl.bindBuffer(GL_ARRAY_BUFFER, buffers[0])
    gl.bufferData(GL_ARRAY_BUFFER, cast[GLintptr](sizeof(vertices)), addr(vertices), GL_STATIC_DRAW)

    gl.vertexAttribPointer(0, 3, GL_EFLOAT, GL_FALSE, cast[GLsizei](3 * sizeof(GLfloat)), nil)
    gl.enableVertexAttribArray(0)

    echo(translate(localplayer.pos))

    while not exit:
        exit = processEvents(wnd, inpsys)

        update(localplayer, 0.16)

        let mvp = translate(localplayer.pos)
        let mvp_location = prog.program.getUniformLocation("matMVP")
        gl.uniformMatrix4fv(mvp_location, 1, GL_FALSE, value_ptr(mvp))

        gl.clear(GL_COLOR_BUFFER_BIT)

        gl.bindVertexArray(arrays[0])
        prog.useProgram()
        gl.drawArrays(GL_TRIANGLES, 0, 3)
        swapWindow(wnd)

main()