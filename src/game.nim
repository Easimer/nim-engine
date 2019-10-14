# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import draw_info
import gfx
import vector
import commands

type Entity* = ref object of RootObj
    pos*: vec4

method update(ent: var Entity, dt: float) {.base.} = discard nil
method draw(ent: var Entity, dt: float, drawInfoList: var seq[draw_info]) {.base.} = discard nil

type Drawable* = ref object of Entity
    sprite*: sprite_id

type Player = ref object of Drawable
    vel: vec4
    acc: vec4

method update(p: var Player, dt: float) =
    p.vel += dt * p.acc
    p.pos += dt * p.vel

    # Simulate friction
    p.vel *= 1 - 0.2 * dt

    zeroCheck(p.acc)
    zeroCheck(p.vel)

method draw(d: var Drawable, dt: float, drawInfoList: var seq[draw_info]) =
    drawInfoList.drawAt(d.sprite, d.pos, 0.5, 0.75)

var localplayer: Player

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

var entities : seq[Entity]

import ent_tram

proc game_load*(level: string, g: var Gfx): bool =
    var tram: Tram
    new(localplayer)
    new(tram)
    tram.init(g)
    localplayer.sprite = g.load_sprite("core/tex/uv.jpg")
    entities.add(localplayer)
    entities.add(tram)
    true

proc game_update*(dt: float, g: var Gfx): seq[draw_info] =
    var diseq: seq[draw_info]

    for i in 0 .. len(entities) - 1:
        var ent = entities[i]
        ent.update(dt)
    for i in 0 .. len(entities) - 1:
        var ent = entities[i]
        ent.draw(dt, result)

proc game_get_camera*(): vec4 = localplayer.pos