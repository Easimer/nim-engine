# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import draw_info
import gfx
import vector
import commands

type player = object
    pos: vec4
    vel: vec4
    acc: vec4
    sprite: sprite_id

proc update(p: var player, dt: float) =
    p.vel += dt * p.acc
    p.pos += dt * p.vel

    # Simulate friction
    p.vel *= 1 - 0.2 * dt

    zeroCheck(p.acc)
    zeroCheck(p.vel)

var localplayer: player

defineCommand("+forward"):
    localplayer.acc.y = 8

defineCommand("-forward"):
    localplayer.acc.y = 0

defineCommand("+lstrafe"):
    localplayer.acc.x = -8

defineCommand("-lstrafe"):
    localplayer.acc.x = 0

defineCommand("+rstrafe"):
    localplayer.acc.x = 8

defineCommand("-rstrafe"):
    localplayer.acc.x = 0


defineCommand("+back"):
    localplayer.acc.y = -8

defineCommand("-back"):
    localplayer.acc.y = 0


proc game_load*(level: string, g: var gfx): bool =
    localplayer.sprite = g.load_sprite("core/tex/uv.jpg")
    true

proc game_update*(dt: float, g: var gfx): seq[draw_info] =
    var diseq: seq[draw_info]
    localplayer.update(dt)
    var di: draw_info
    di.position = localplayer.pos
    di.sprite = localplayer.sprite

    result.add(di)

proc game_get_camera*(): vec4 = localplayer.pos