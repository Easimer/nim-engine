# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import draw_info
import gfx
import game
import vector

type Tram* = ref object of Entity
  sprite_head: sprite_id
  sprite_car: sprite_id

proc init*(d: var Tram, g: var gfx) =
  d.sprite_head = g.load_sprite("data/tram001_head.aseprite")
  d.sprite_car = g.load_sprite("data/tram001_car.aseprite")

method draw(t: var Tram, dt: float, drawInfoList: var seq[draw_info]) =
  drawInfoList.drawAt(t.sprite_head, t.pos)
  drawInfoList.drawAt(t.sprite_car, t.pos + vec4(x: -1, y: 0, z: 0, w: 0))