# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import sdl2
import input
import commands
import vector
import game
import gfx

var exit = false

proc sighandler() {.noconv.} =
    exit = true

type player = object
    pos: vec4
    vel: vec4
    acc: vec4

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

proc main() =
    var inpsys: input_system
    setControlCHook(sighandler)

    inpsys.bindKey(K_w, "+forward")
    inpsys.bindKey(K_a, "+lstrafe")
    inpsys.bindKey(K_s, "+back")
    inpsys.bindKey(K_d, "+rstrafe")

    var g: gfx
    g.init()

    while not exit:
        exit = g.update(inpsys)
        g.clear()
        g.draw(game.game_update(0.016, g))
        g.flip()

    destroy(g)

main()