# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

const
  GL_DEPTH_BUFFER_BIT*        = 0x00000100
  GL_STENCIL_BUFFER_BIT*      = 0x00000400
  GL_COLOR_BUFFER_BIT*        = 0x00004000
  GL_FALSE*                   = 0
  GL_TRUE*                    = 1

type
  GLbitfield = uint

type
  PFNGETPROCADDR = (proc(name: string): pointer)
  PFNGLCLEARPROC = (proc(mask: GLbitfield) {.cdecl.})

var clear*: PFNGLCLEARPROC

proc load_functions*(loader: PFNGETPROCADDR) =
  clear = cast[PFNGLCLEARPROC](loader("glClear"))
