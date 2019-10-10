# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import os
import sdl2/wrapper

proc initialize_window() =
  SDL_SetMainReady()
  var res = SDL_Init(SDL_INIT_EVERYTHING)

  let window = SDL_CreateWindow("Test", 10, 10, 800, 600, SDL_WINDOW_SHOWN)
  let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC)
  os.sleep(1000)
  SDL_DestroyWindow(window)

initialize_window()
