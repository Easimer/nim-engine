# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import draw_info
import gfx
import game
import vector
import random

type Tram* = ref object of Entity
  spriteHead: sprite_id
  spriteCars: seq[sprite_id]
  timer: float

proc init*(d: var Tram, g: var Gfx) =
  d.sprite_head = gGfx.load_sprite("data/tram001_head.aseprite")
  for i in 0..3:
    d.spriteCars.add(gGfx.load_sprite("data/tram001_car.aseprite"))

method update(t: var Tram, dt: float) =
  t.timer += dt
  if t.timer > 0.25:
    t.timer = 0
    let carIdx = rand(t.spriteCars.len - 1)
    let visible = gGfx.getLayerVisible(t.spriteCars[carIdx], "Buttons - Green")
    gGfx.setLayerVisible(t.spriteCars[carIdx], "Buttons - Green", not visible)

method draw(t: var Tram, dt: float, drawInfoList: var seq[draw_info]) =
  drawInfoList.drawAt(t.sprite_head, t.pos, 1.25, 1)
  for i, spriteCar in t.spriteCars:
    drawInfoList.drawAt(spriteCar, t.pos + vec4(x: -1.125 - i.float, y: 0, z: 0, w: 0))