# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import sdl2
import input
import commands
import vector
import game
import gfx
import ase

var exit = false

proc sighandler() {.noconv.} =
    exit = true


proc main() =
    var inpsys: input_system
    setControlCHook(sighandler)

    discard ase.loadSprite("data/tram001_head.aseprite")

    inpsys.bindKey(K_w, "+forward")
    inpsys.bindKey(K_a, "+lstrafe")
    inpsys.bindKey(K_s, "+back")
    inpsys.bindKey(K_d, "+rstrafe")

    var g: gfx
    g.init()

    var frame_start = sdl2.getPerformanceCounter()
    var frame_end = frame_start

    if game.game_load("none", g):
        while not exit:
            let dt: float = cast[float](frame_end - frame_start) / cast[float](sdl2.getPerformanceFrequency())
            frame_start = sdl2.getPerformanceCounter()
            exit = g.update(inpsys)
            g.clear()
            g.move_camera(game.game_get_camera())
            g.draw(game.game_update(dt, g))
            g.flip()
            frame_end = sdl2.getPerformanceCounter()
    else:
        echo("game_load has failed, exiting.")

    destroy(g)

main()