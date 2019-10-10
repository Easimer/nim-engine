# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import os
import sdl2

sdl2.init()
defer: sdl2.shutdown()
let window = sdl2.create_window("Nim Engine", 640, 480)
defer: sdl2.destroy_window(window)

os.sleep(1000)
