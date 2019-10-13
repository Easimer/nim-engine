# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import math
import vector

type matrix4* = array[16, float32]

proc `*`*(lhs: matrix4, rhs: vec4): vec4 =
    result.x = 0
    result.y = 0
    result.z = 0
    result.w = 0
    for col in 0..3:
        result.x += lhs[col * 4 + 0] * rhs[col]
        result.y += lhs[col * 4 + 1] * rhs[col]
        result.z += lhs[col * 4 + 2] * rhs[col]
        result.w += lhs[col * 4 + 3] * rhs[col]

proc `*`*(lhs: matrix4, rhs: matrix4): matrix4 =
    for row in 0..3:
        for col in 0..3:
            result[col * 4 + row] = 0
            for i in 0..3:
                result[col * 4 + row] += lhs[i * 4 + row] * rhs[col * 4 + i]
    
proc identity(): matrix4 =
    result[0] = 1
    result[5] = 1
    result[10] = 1
    result[15] = 1

proc translate*(v: vec4): matrix4 =
    result = identity()
    result[12] = v[0]
    result[13] = v[1]
    result[14] = v[2]

proc value_ptr*(mat: matrix4): array[16, float32] = cast[array[16, float32]](mat)

proc rotateZ*(theta: float32): matrix4 =
    result = identity()
    result[0] = cos(theta)
    result[1] = sin(theta)
    result[4] = -sin(theta)
    result[5] = cos(theta)