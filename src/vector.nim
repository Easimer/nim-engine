# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import math

type vec4* = object
    x*: float
    y*: float
    z*: float
    w*: float

proc `[]`*(lhs: vec4, rhs: int): float =
    case rhs:
        of 0: result = lhs.x
        of 1: result = lhs.y
        of 2: result = lhs.z
        of 3: result = lhs.w
        else: result = 0

proc `[]=`*(lhs: var vec4, idx: int, rhs: float) =
    case idx:
        of 0:
            lhs.x = rhs
        of 1:
            lhs.y = rhs
        of 2:
            lhs.z = rhs
        of 3:
            lhs.w = rhs
        else: discard nil

proc zeroCheck*(v: var vec4) =
    for i in 0..3:
        if abs(v[i]) < 0.01:
            v[i] = 0

proc dot(lhs: vec4, rhs: vec4): float =
    result = lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z + lhs.w * rhs.w

proc len_sq*(v: vec4): float =
    result = dot(v, v)

proc len*(v: vec4): float =
    result = sqrt(len_sq(v))

proc `+`*(lhs: vec4, rhs: vec4): vec4 =
    for i in 0..3:
        result[i] = lhs[i] + rhs[i]

proc `-`*(lhs: vec4, rhs: vec4): vec4 =
    for i in 0..3:
        result[i] = lhs[i] - rhs[i]

proc `*`*(lhs: float, rhs: vec4): vec4 =
    for i in 0..3:
        result[i] = lhs * rhs[i]

proc `*`*(lhs: vec4, rhs: float): vec4 =
    result = rhs * lhs

proc `/`*(lhs: vec4, rhs: float): vec4 =
    for i in 0..3:
        result[i] = lhs[i] / rhs

proc `+=`*(lhs: var vec4, rhs: vec4) =
    for i in 0..3:
        lhs[i] = lhs[i] + rhs[i]

proc `-=`*(lhs: var vec4, rhs: vec4) =
    for i in 0..3:
        lhs[i] = lhs[i] - rhs[i]

proc `*=`*(lhs: var vec4, rhs: float) =
    for i in 0..3:
        lhs[i] = rhs * lhs[i]