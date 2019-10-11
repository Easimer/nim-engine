# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

{.passC: "-I/usr/include/SDL2/".}
{.passL: "-lSDL2 -lrt".}
{.deadCodeElim: on.}

{.pragma: sdl2,
   cdecl,
   header: "<SDL.h>",
   importc.}

import macros

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

const
  SDL_FIRSTEVENT*               = 0x0000
  SDL_EV_QUIT*                  = 0x0100
  SDL_APP_TERMINATING*          = 0x0101
  SDL_APP_LOWMEMORY*            = 0x0102
  SDL_APP_WILLENTERBACKGROUND*  = 0x0103
  SDL_APP_DIDENTERBACKGROUND*   = 0x0104
  SDL_APP_WILLENTERFOREGROUND*  = 0x0105
  SDL_APP_DIDENTERFOREGROUND*   = 0x0106
  SDL_DISPLAYEVENT*             = 0x0150
  SDL_WINDOWEVENT*              = 0x0200
  SDL_SYSWMEVENT*               = 0x0201
  SDL_KEYDOWN*                  = 0x0300
  SDL_KEYUP*                    = 0x0301
  SDL_TEXTEDITING*              = 0x0302
  SDL_TEXTINPUT*                = 0x0303
  SDL_KEYMAPCHANGED*            = 0x0304
  SDL_MOUSEMOTION*              = 0x0400
  SDL_MOUSEBUTTONDOWN*          = 0x0401
  SDL_MOUSEBUTTONUP*            = 0x0402
  SDL_MOUSEWHEEL*               = 0x0403
  SDL_USEREVENT*                = 0x8000
  SDL_LASTEVENT*                = 0xFFFF

const
  SDL_SCANCODE_F1*    = 58
  SDL_SCANCODE_F2*    = 59
  SDL_SCANCODE_F3*    = 60
  SDL_SCANCODE_F4*    = 61
  SDL_SCANCODE_F5*    = 62
  SDL_SCANCODE_F6*    = 63
  SDL_SCANCODE_F7*    = 64
  SDL_SCANCODE_F8*    = 65
  SDL_SCANCODE_F9*    = 66
  SDL_SCANCODE_F10*   = 67
  SDL_SCANCODE_F11*   = 68
  SDL_SCANCODE_F12*   = 69

const
  SDLK_SCANCODE_MASK = (1 shl 30)

type SDL_Keycode = enum
  SDLK_UNKNOWN = 0
  SDLK_BACKSPACE = 8
  SDLK_TAB = 9
  SDLK_RETURN = 13
  SDLK_ESCAPE = 27
  SDLK_SPACE = 32
  SDLK_EXCLAIM = 33
  SDLK_QUOTEDBL = 34
  SDLK_HASH = 35
  SDLK_PERCENT = 36
  SDLK_DOLLAR = 37
  SDLK_AMPERSAND = 38
  SDLK_QUOTE = 39
  SDLK_LEFTPAREN = 40
  SDLK_RIGHTPAREN = 41
  SDLK_ASTERISK = 42
  SDLK_PLUS = 43
  SDLK_COMMA = 44
  SDLK_MINUS = 45
  SDLK_PERIOD = 46
  SDLK_SLASH = 47
  SDLK_0 = 48
  SDLK_1 = 49
  SDLK_2 = 50
  SDLK_3 = 51
  SDLK_4 = 52
  SDLK_5 = 53
  SDLK_6 = 54
  SDLK_7 = 55
  SDLK_8 = 56
  SDLK_9 = 57
  SDLK_COLON = 58
  SDLK_SEMICOLON = 59
  SDLK_LESS = 60
  SDLK_EQUALS = 61
  SDLK_GREATER = 62
  SDLK_QUESTION = 63
  SDLK_AT = 64
  # Skip uppercase letters
  SDLK_LEFTBRACKET = 91
  SDLK_BACKSLASH = 92
  SDLK_RIGHTBRACKET = 93
  SDLK_CARET = 94
  SDLK_UNDERSCORE = 95
  SDLK_BACKQUOTE = 96
  SDLK_a = 97
  SDLK_b = 98
  SDLK_c = 99
  SDLK_d = 100
  SDLK_e = 101
  SDLK_f = 102
  SDLK_g = 103
  SDLK_h = 104
  SDLK_i = 105
  SDLK_j = 106
  SDLK_k = 107
  SDLK_l = 108
  SDLK_m = 109
  SDLK_n = 110
  SDLK_o = 111
  SDLK_p = 112
  SDLK_q = 113
  SDLK_r = 114
  SDLK_s = 115
  SDLK_t = 116
  SDLK_u = 117
  SDLK_v = 118
  SDLK_w = 119
  SDLK_x = 120
  SDLK_y = 121
  SDLK_z = 122
  SDLK_F1 = (SDL_SCANCODE_F1 or SDLK_SCANCODE_MASK)

type SDL_Scancode = int32

type SDL_Keysym = object
  scancode: SDL_Scancode
  sym: SDL_Keycode
  modifiers: uint16
  unused: uint32

type SDL_CommonEvent = object
  ev_type: uint32
  timestamp: uint32

type SDL_KeyboardEvent = object
  ev_type: uint32
  timestamp: uint32
  windowID: uint32
  state: uint8
  repeat: uint8
  padding2: uint8
  padding3: uint8
  keysym: SDL_Keysym

type SDL_MouseMotionEvent = object
  ev_type: uint32
  timestamp: uint32
  windowID: uint32
  which: uint32
  state: uint32
  x: int32
  y: int32
  xrel: int32
  yrel: int32

type SDL_MouseButtonEvent = object
  ev_type: uint32
  timestamp: uint32
  windowID: uint32
  which: uint32
  button: uint8
  state: uint8
  clicks: uint8
  padding1: uint8
  x: int32
  y: int32

type SDL_MouseWheelEvent = object
  ev_type: uint32
  timestamp: uint32
  windowID: uint32
  which: uint32
  x: int32
  y: int32
  direction: uint32



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