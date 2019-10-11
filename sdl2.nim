# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import sdl2/wrapper

type
  sdl_window = object
    wnd: ptr SDL_Window
    renderer: ptr SDL_Renderer
    glctx: ptr SDL_GLContext
    received_quit_event: bool

proc init*() =
  SDL_SetMainReady()
  discard SDL_Init(SDL_INIT_EVERYTHING)

proc shutdown*() =
  SDL_Quit()

proc create_window*(name: string, w: int, h: int): sdl_window =
  result.wnd = SDL_CreateWindow(name, 100, 100, w, h, SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL)
  result.renderer = SDL_CreateRenderer(result.wnd, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC)
  result.received_quit_event = false

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24)
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1)
  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4)

  result.glctx = SDL_GL_CreateContext(result.wnd)
  discard SDL_SetRelativeMouseMode(SDL_TRUE)
  SDL_GL_SetSwapInterval(-1)

proc destroy_window*(window: sdl_window) =
  if window.glctx != nil:
    SDL_GL_DeleteContext(window.glctx)
  if window.renderer != nil:
    SDL_DestroyRenderer(window.renderer)
  if window.wnd != nil:
    SDL_DestroyWindow(window.wnd)

proc swap_buffers*(window: sdl_window) =
  if window.wnd != nil:
    SDL_GL_SwapWindow(window.wnd)

proc gl_loader*(name: string): pointer =
  SDL_GL_GetProcAddress(name)

proc poll_events*(window: sdl_window) =
  if window.wnd != nil:
    var ev: SDL_Event
    SDL_PollEvent(ev)

proc should_close*(window: sdl_window): bool = window.received_quit_event
