# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import draw_info
import gl
import sdl2
import winmgr
import vector
import matrix
import input
import stb_image/read as stbi
import ase
import strutils

type ShaderProgram = object
    shader_vertex: GLshaderID
    shader_fragment: GLshaderID
    program: GLprogramID

type SpriteLayer = object
    textureID: GLtexture

type SpriteFrame = object
    layers: seq[SpriteLayer]

type Sprite = object
    frames: seq[SpriteFrame]
    currentFrame: int


type gfx* = object
    wnd: window
    quad: GLVAO
    shaderSprite: ShaderProgram
    sprites: seq[Sprite]
    mat_view: matrix4

proc debugCallback(source: GLenum, msgtype: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: cstring, userParam: pointer) {.cdecl.} =
    echo "OpenGL: " & $message

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

proc createQuad(): GLVAO =
    var vertices: array[18, GLfloat] = [
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        -0.5f,  0.5f, 0.0f,
        -0.5f,  0.5f, 0.0f,
        0.5f,  0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f,
    ]

    var uv: array[12, GLfloat] = [
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    ]

    var buffers: array[2, GLVBO]
    var arrays: array[1, GLVAO]

    gl.genVertexArrays(1, addr arrays)
    gl.bindVertexArray(arrays[0])

    gl.genBuffers(2, addr buffers)

    gl.bindBuffer(GL_ARRAY_BUFFER, buffers[0])
    gl.bufferData(GL_ARRAY_BUFFER, cast[GLintptr](sizeof(vertices)), addr(vertices), GL_STATIC_DRAW)
    gl.vertexAttribPointer(0, 3, GL_EFLOAT, GL_FALSE, cast[GLsizei](3 * sizeof(GLfloat)), nil)
    gl.enableVertexAttribArray(0)

    gl.bindBuffer(GL_ARRAY_BUFFER, buffers[1])
    gl.bufferData(GL_ARRAY_BUFFER, cast[GLintptr](sizeof(uv)), addr(uv), GL_STATIC_DRAW)
    gl.vertexAttribPointer(1, 2, GL_EFLOAT, GL_FALSE, cast[GLsizei](2 * sizeof(GLfloat)), nil)
    gl.enableVertexAttribArray(1)
    
    arrays[0]
    

proc init*(g: var gfx) =
    g.wnd = openWindow(640, 480)
    gl.load_functions(glGetProcAddress)
    gl.enable(GL_DEBUG_OUTPUT)
    gl.debugMessageCallback(debugCallback, nil)
    gl.clearColor(0.392, 0.584, 0.929, 1.0)
    gl.viewport(0, 0, 640, 480)
    gl.enable(GL_BLEND)
    gl.blendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    g.quad = createQuad()
    g.shaderSprite = loadShaderProgramFromFile("core/shaders/sprite.vrtx.glsl", "core/shaders/sprite.frag.glsl")

proc destroy*(g: var gfx) =
    destroy(g.shaderSprite)
    closeWindow(g.wnd)

proc clear*(g: var gfx) =
    gl.clear(GL_COLOR_BUFFER_BIT)

proc flip*(g: var gfx) =
    swapWindow(g.wnd)

proc update*(g: var gfx, inpsys: var input_system): bool =
    processEvents(g.wnd, inpsys)

proc move_camera*(g: var gfx, pos: vec4) =
    g.mat_view = translate(-pos)

proc draw*(g: var gfx, diseq: seq[draw_info]) =
    gl.bindVertexArray(g.quad)
    g.shaderSprite.useProgram()
    let mvp_location = g.shaderSprite.program.getUniformLocation("matMVP")
    for di in diseq:
        let mat_world = translate(di.position)
        gl.uniformMatrix4fv(mvp_location, 1, GL_FALSE, value_ptr(g.mat_view * mat_world))
        let sprite = g.sprites[cast[uint32](di.sprite)]
        let spriteFrame = sprite.frames[sprite.currentFrame]
        #for i in countdown(len(spriteFrame.layers) - 1, 0):
        for i in countup(0, len(spriteFrame.layers) - 1):
            gl.bindTexture(GL_TEXTURE_2D, spriteFrame.layers[i].textureID)
            gl.drawArrays(GL_TRIANGLES, 0, 6)

proc uploadTexture(width: int, height: int, data: var seq[uint8]): GLtexture =
    gl.genTextures(1, addr result)
    gl.bindTexture(GL_TEXTURE_2D, result)
    gl.texParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    gl.texParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    gl.texParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    gl.texParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)

    gl.texImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, addr data[0])
    gl.generateMipmap(GL_TEXTURE_2D)

proc load_sprite*(g: var gfx, path: string): sprite_id =
    var
        s: Sprite


    if path.endsWith(".aseprite"):
        let img = ase.loadSprite(path)
        let width = img.width
        let height = img.height
        for fidx in 0 .. img.numberOfFrames() - 1:
            var frame: SpriteFrame
            for lidx in 0 .. img.numberOfLayers(fidx) - 1:
                var data = img.rasterizeLayer(fidx, lidx)
                frame.layers.add:
                    SpriteLayer(
                        textureID: uploadTexture(width, height, data)
                    )
            s.frames.add(frame)

    else:
        # Non aseprite-image: 1 frame with 1 layer only
        var
            width, height, channels: int
            data: seq[uint8]
        data = stbi.load(path, width, height, channels, stbi.RGBA)
        var layer = SpriteLayer(
            textureID: uploadTexture(width, height, data)
        )
        var frame = SpriteFrame()
        frame.layers.add(layer)
        s.frames.add(frame)
    
    result = cast[sprite_id](len(g.sprites))
    g.sprites.add(s)
