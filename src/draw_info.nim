# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import vector

type sprite_id* = distinct uint32

type draw_info* = object
    position*: vec4
    rotation*: float32
    sprite*: sprite_id