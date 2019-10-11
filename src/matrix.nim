# === Copyright (c) 2019-2020 easimer.net. All rights reserved. ===

import vector

type matrix4* = array[16, float]

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
    for i in 0..3:
        for j in 0..3:
            result[i * 4 + j] = lhs[i * 4 + j] * rhs[j * 4 + i]

proc translate(v: vec4): matrix4 =
    result[12] = v[0]
    result[13] = v[1]
    result[14] = v[2]
    result[15] = v[3]

proc identity(): matrix4 =
    result[0] = 1
    result[5] = 1
    result[10] = 1
    result[15] = 1
            