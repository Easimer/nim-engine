# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

const
  GL_DEPTH_BUFFER_BIT*        = 0x00000100
  GL_STENCIL_BUFFER_BIT*      = 0x00000400
  GL_COLOR_BUFFER_BIT*        = 0x00004000
  GL_FALSE*                   = 0
  GL_TRUE*                    = 1

type
  GLbitfield = uint32
  GLfloat = float32

type
  PFNGETPROCADDR = (proc(name: string): pointer)
  PFNGLCLEARPROC = (proc(mask: GLbitfield) {.cdecl.})
  PFNGLCLEARCOLORPROC = (proc(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) {.cdecl.})

var clear*: PFNGLCLEARPROC
var clearColor*: PFNGLCLEARCOLORPROC

proc load_functions*(loader: PFNGETPROCADDR) =
  clear = cast[PFNGLCLEARPROC](loader("glClear"))
  clearColor = cast[PFNGLCLEARCOLORPROC](loader("glClearColor"))