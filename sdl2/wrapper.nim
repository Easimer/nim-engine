# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

{.passC: "-I/usr/include/SDL2/".}
{.passL: "-lSDL2 -lrt".}
{.deadCodeElim: on.}

{.pragma: sdl2,
   cdecl,
   header: "<SDL.h>",
   importc.}

type
  SDL_Window* = object
  SDL_Renderer* = object
  SDL_GLContext* = object

const
  SDL_INIT_TIMER*          = 0x00000001
  SDL_INIT_AUDIO*          = 0x00000010
  SDL_INIT_VIDEO*          = 0x00000020
  SDL_INIT_JOYSTICK*       = 0x00000200
  SDL_INIT_HAPTIC*         = 0x00001000
  SDL_INIT_GAMECONTROLLER* = 0x00002000
  SDL_INIT_EVENTS*         = 0x00004000
  SDL_INIT_SENSOR*         = 0x00008000
  SDL_INIT_NOPARACHUTE*    = 0x00100000
  SDL_INIT_EVERYTHING*     = SDL_INIT_TIMER or SDL_INIT_AUDIO or SDL_INIT_VIDEO or SDL_INIT_JOYSTICK or SDL_INIT_HAPTIC or SDL_INIT_GAMECONTROLLER or SDL_INIT_EVENTS or SDL_INIT_SENSOR or SDL_INIT_NOPARACHUTE

const
  SDL_RENDERER_SOFTWARE*      = 0x00000001
  SDL_RENDERER_ACCELERATED*   = 0x00000002
  SDL_RENDERER_PRESENTVSYNC*  = 0x00000004
  SDL_RENDERER_TARGETTEXTURE* = 0x00000008

const
  SDL_WINDOW_OPENGL*       = 0x00000002
  SDL_WINDOW_SHOWN*        = 0x00000004

const
  SDL_GL_DOUBLEBUFFER*          = 5
  SDL_GL_DEPTH_SIZE*            = 6
  SDL_GL_MULTISAMPLEBUFFERS*    = 13
  SDL_GL_MULTISAMPLESAMPLES*    = 14
  SDL_GL_CONTEXT_MAJOR_VERSION* = 17
  SDL_GL_CONTEXT_MINOR_VERSION* = 18
  SDL_GL_CONTEXT_PROFILE_MASK*  = 21

const
  SDL_FALSE* = 0
  SDL_TRUE*  = 1

const
  SDL_GL_CONTEXT_PROFILE_CORE* = 0x0001

# Library initialization
proc SDL_SetMainReady*() {.
  cdecl, importc: "SDL_SetMainReady".}

proc SDL_Init*(flags: uint32): int {.
  cdecl, importc: "SDL_Init".}
proc SDL_Quit*() {.
  cdecl, importc: "SDL_Quit".}

# Window management
proc SDL_CreateWindow*(title: cstring; x: int; y: int; w: int; h: int, flags: uint32): ptr SDL_Window {.cdecl, importc: "SDL_CreateWindow".}
proc SDL_DestroyWindow*(window: ptr SDL_Window) {.cdecl, importc: "SDL_DestroyWindow".}

# Renderer management
proc SDL_CreateRenderer*(window: ptr SDL_Window; index: int; flags: uint32): ptr SDL_Renderer {.cdecl, importc: "SDL_CreateRenderer".}
proc SDL_DestroyRenderer*(renderer: ptr SDL_Renderer) {.cdecl, importc: "SDL_DestroyRenderer".}

# OpenGL
proc SDL_GL_CreateContext*(window: ptr SDL_Window): ptr SDL_GLContext {.cdecl, importc: "SDL_GL_CreateContext".}
proc SDL_GL_DeleteContext*(ctx: ptr SDL_GLContext) {.cdecl, importc: "SDL_GL_DeleteContext".}
proc SDL_GL_SetAttribute*(attr: uint32; value: int) {.cdecl, importc: "SDL_GL_SetAttribute".}

proc SDL_SetRelativeMouseMode*(enabled: int): int {.cdecl, importc: "SDL_SetRelativeMouseMode".}
proc SDL_GL_SetSwapInterval*(interval: int) {.cdecl, importc: "SDL_GL_SetSwapInterval".}
proc SDL_GL_SwapWindow*(window: ptr SDL_Window) {.cdecl, importc: "SDL_GL_SwapWindow".}
proc SDL_GL_GetProcAddress*(name: cstring): pointer {.cdecl, importc: "SDL_GL_GetProcAddress".}
