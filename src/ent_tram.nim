# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import draw_info
import gfx
import game
import vector

type Tram* = ref object of Entity
  sprite_head: sprite_id
  sprite_car: sprite_id
  timer: float

proc init*(d: var Tram, g: var gfx) =
  d.sprite_head = gGfx.load_sprite("data/tram001_head.aseprite")
  d.sprite_car = gGfx.load_sprite("data/tram001_car.aseprite")

method update(t: var Tram, dt: float) =
  t.timer += dt
  if t.timer > 1.0:
    t.timer = 0
    let visible = gGfx.getLayerVisible(t.sprite_car, "Buttons - Green")
    gGfx.setLayerVisible(t.sprite_car, "Buttons - Green", not visible)

method draw(t: var Tram, dt: float, drawInfoList: var seq[draw_info]) =
  drawInfoList.drawAt(t.sprite_head, t.pos)
  for i in 1..4:
    drawInfoList.drawAt(t.sprite_car, t.pos + vec4(x: -i.float, y: 0, z: 0, w: 0))