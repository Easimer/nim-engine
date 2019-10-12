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


proc main() =
    var inpsys: input_system
    setControlCHook(sighandler)

    inpsys.bindKey(K_w, "+forward")
    inpsys.bindKey(K_a, "+lstrafe")
    inpsys.bindKey(K_s, "+back")
    inpsys.bindKey(K_d, "+rstrafe")

    var g: gfx
    g.init()

    var frame_start = sdl2.getPerformanceCounter()
    var frame_end: uint64 = frame_start

    if game.game_load("none", g):
        while not exit:
            let dt: float = cast[float](frame_end - frame_start) / cast[float](sdl2.getPerformanceFrequency())
            frame_start = sdl2.getPerformanceCounter()
            exit = g.update(inpsys)
            g.clear()
            g.draw(game.game_update(dt, g))
            g.flip()
            frame_end = sdl2.getPerformanceCounter()
    else:
        echo("game_load has failed, exiting.")

    destroy(g)

main()