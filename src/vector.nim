# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

type vec2* = object
    x*: float
    y*: float

proc zeroCheck*(v: var vec2) =
    if abs(v.x) < 0.05:
        v.x = 0
    if abs(v.y) < 0.05:
        v.y = 0

