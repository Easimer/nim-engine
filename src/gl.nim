# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import macros
import strutils

type
  GLenum* = uint
  GLboolean* = uint8
  GLbitfield* = uint32
  GLvoid* = void
  GLbyte* = int8
  GLshort* = int16
  GLint* = int
  GLclampx* = int
  GLubyte* = uint8
  GLushort* = uint16
  GLuint* = uint32
  GLsizei* = int
  GLfloat* = float32
  GLclampf* = float32
  GLdouble* = float64
  GLclampd* = float64
  GLchar* = int8
  GLintptr* = int64
  GLsizeiptr* = int64
  GLshaderID* = distinct GLuint
  GLprogramID* = distinct GLuint
  GLVAO* = distinct GLuint
  GLVBO* = distinct GLuint
  GLDEBUGPROC* = proc(source: GLenum, msgtype: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: cstring, userParam: pointer) {.cdecl.}

const
  GL_DEPTH_BUFFER_BIT*        = 0x00000100
  GL_STENCIL_BUFFER_BIT*      = 0x00000400
  GL_COLOR_BUFFER_BIT*        = 0x00004000
  GL_FALSE*       : GLboolean = 0
  GL_TRUE*        : GLboolean = 1
  GL_VERTEX_SHADER*           = 0x8B31
  GL_FRAGMENT_SHADER*         = 0x8B30
  GL_ARRAY_BUFFER*   : GLenum = 0x8892
  GL_STATIC_DRAW*    : GLenum = 0x88E4
  GL_EFLOAT*         : GLenum = 0x1406
  GL_TRIANGLES*      : GLenum = 0x0004
  GL_DEBUG_OUTPUT*   : GLenum = 0x92E0
  GL_LINK_STATUS*    : GLenum = 0x8B82
  GL_COMPILE_STATUS* : GLenum = 0x8B81

#region loadGLAPI implementation

type
  PFNGETPROCADDR = (proc(name: cstring): pointer {.cdecl.})

proc addProcTypedef(proctypeSection : NimNode, name: string; procty: NimNode) =
  expectKind(procty, nnkProcTy)

  proctypeSection.add(nnkTypeDef.newTree(
      newIdentNode(name),
      newEmptyNode(),
      procty
    )
  )

proc addFuncptr(funcptr_list: NimNode, procname: string, proctypename: string) =
  expectKind(funcptr_list, nnkStmtList)

  funcptr_list.add(
    nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        postfix(newIdentNode(procname), "*"),
        newIdentNode(proctypename),
        newEmptyNode()
      )
    )
  )

proc addLoadStatement(loading_statements: NimNode, procname: string, proctypename: string, sym: string) =
  expectKind(loading_statements, nnkStmtList)

  loading_statements.add(
    nnkAsgn.newTree(
      newIdentNode(procname),
      nnkCast.newTree(
        newIdentNode(proctypename),
        nnkCall.newTree(
          newIdentNode("loader"),
          newLit(sym)
        )
      )
    )
  )

macro loadGLAPI(api_entries: untyped): untyped =
  api_entries.expectMinLen(2)
  result = newStmtList()

  # Contains the function pointer typedefs
  let proctype_section = nnkTypeSection.newTree()
  # Lists the function pointer entries
  let funcptr_list = nnkStmtList.newTree()
  # Contains the procedure loading statements of load_functions()
  let loading_statements = nnkStmtList.newTree()
  # Build procedure load_functions
  let load_functions_proc = nnkProcDef.newTree(
    nnkPostfix.newTree(
      newIdentNode("*"),
      newIdentNode("load_functions")
    ),
    newEmptyNode(),
    newEmptyNode(),
    nnkFormalParams.newTree(
      newEmptyNode(),
      nnkIdentDefs.newTree(
        newIdentNode("loader"),
        newIdentNode("PFNGETPROCADDR"),
        newEmptyNode()
      )
    ),
    newEmptyNode(),
    newEmptyNode(),
    loading_statements
  )

  for api in api_entries:
    let sym = $api[0]
    
    
    var procname: string 
    if api.len() <= 2:
      # Generate nim procedure name from C symbol
      if not sym.startsWith("gl"):
        funcptr_list.add(
          nnkPragma.newTree(
            nnkCall.newTree(
              newIdentNode("warning"),
              newLit("Symbol name '$1' doesn't start with 'gl'! Are you sure this is an OpenGL function?" % (sym))
            )
          )
        )

      procname = sym[2..^1]
      procname[0] = procname[0].toLowerAscii()
    elif api.len() > 2:
      # Nim procedure name was explicitly provided
      procname = $api[1]

    let proctypename = procname & "_t"
    let proctype = api.last()

    proctype_section.addProcTypedef(proctypename, proctype)
    funcptr_list.addFuncptr(procname, proctypename)
    loading_statements.addLoadStatement(procname, proctypename, sym)
  
  result.add proctype_section
  result.add funcptr_list
  result.add load_functions_proc

#endregion

# (C symbol name[, Nim procedure name], Procedure type)
loadGLAPI:
  ("glClear", proc(mask: GLbitfield) {.cdecl.})
  ("glClearColor", proc(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) {.cdecl.})
  ("glViewport", proc(x: int, y: int, w: int, h: int) {.cdecl.})
  ("glGenBuffers", proc(n: GLsizei, buffers: ptr array[0..0, GLVBO]) {.cdecl.})
  ("glBindBuffer", proc(target: GLenum, buffer: GLVBO) {.cdecl.})
  ("glBufferData", proc(target: GLenum, size: GLsizeiptr, data: pointer, usage: GLenum) {.cdecl.})
  ("glCreateShader", proc(shader_type: GLenum): GLshaderID {.cdecl.})
  ("glDeleteShader", proc(shader: GLshaderID) {.cdecl.})
  ("glShaderSource", proc(shader: GLshaderID, count: GLsizei, source: ptr cstring, length: ptr GLint) {.cdecl.})
  ("glCompileShader", proc(shader: GLshaderID) {.cdecl.})
  ("glCreateProgram", proc(): GLprogramID {.cdecl.})
  ("glDeleteProgram", proc(program: GLprogramID) {.cdecl.})
  ("glAttachShader", proc(program: GLprogramID, shader: GLshaderID) {.cdecl.})
  ("glLinkProgram", proc(program: GLprogramID) {.cdecl.})
  ("glUseProgram", proc(program: GLprogramID) {.cdecl.})
  ("glVertexAttribPointer", proc(index: GLuint, size: GLint, attrtype: GLenum, normalized: GLboolean, stride: GLsizei, bpointer: pointer) {.cdecl.})
  ("glEnableVertexAttribArray", proc(index: GLuint) {.cdecl.})
  ("glGenVertexArrays", proc(n: GLsizei, buffer: ptr array[0..0, GLVAO]) {.cdecl.})
  ("glBindVertexArray", proc(vao: GLVAO) {.cdecl.})
  ("glDrawArrays", proc(mode: GLenum, first: GLint, count: GLsizei) {.cdecl.})
  ("glGetError", proc(): GLenum {.cdecl.})
  ("glEnable", proc(cap: GLenum) {.cdecl.})
  ("glDisable", proc(cap: GLenum) {.cdecl.})
  ("glDebugMessageCallback", proc(callback: GLDEBUGPROC, userParam: pointer) {.cdecl.})
  ("glGetProgramiv", "getProgram", proc(program: GLprogramID, pname: GLenum, params: array[0..0, GLint]) {.cdecl.})
  ("glGetShaderiv", "getShader", proc(shader: GLshaderID, pname: GLenum, params: array[0..0, GLint]) {.cdecl.})