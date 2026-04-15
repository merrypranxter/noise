// shaders/glsl/simplex.glsl
// Simplex gradient noise, 2D/3D/4D variants.
// Based on Ashima Arts / Stefan Gustavson (stegu/webgl-noise).
// Adapted for noise_fields pack.

#ifndef NOISE_FIELDS_SIMPLEX_GLSL
#define NOISE_FIELDS_SIMPLEX_GLSL

// Shared helpers (safe to include alongside perlin.glsl due to guard macros)
#ifndef _NF_COMMON_GLSL
#define _NF_COMMON_GLSL
vec3 _nf_mod289_3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 _nf_mod289_4(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 _nf_mod289_2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 _nf_perm(vec4 x) { return _nf_mod289_4(((x * 34.0) + 10.0) * x); }
vec3 _nf_perm3(vec3 x) { return _nf_mod289_3(((x * 34.0) + 10.0) * x); }
vec4 _nf_tis(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
#endif

// --- 2D Simplex noise ---
// Returns value in approx [-1, 1]

float simplexNoise2D(vec2 v) {
    const vec4 C = vec4(
        0.211324865405187,   // (3.0 - sqrt(3.0)) / 6.0
        0.366025403784439,   // 0.5 * (sqrt(3.0) - 1.0)
       -0.577350269189626,   // -1.0 + 2.0 * C.x
        0.024390243902439    // 1.0 / 41.0
    );

    // First corner
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Other corners
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = _nf_mod289_2(i);
    vec3 p = _nf_perm3(_nf_perm3(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));

    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;

    // Gradients
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalize gradients implicitly via Taylor approx
    m *= _nf_tis(vec4(a0 * a0 + h * h, 0.0)).xyz;

    // Compute final noise value at P
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.y = a0.y * x12.x + h.y * x12.y;
    g.z = a0.z * x12.z + h.z * x12.w;
    return 130.0 * dot(m, g);
}

// --- 3D Simplex noise ---
// Returns value in approx [-1, 1]

float simplexNoise3D(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    // Permutations
    i = _nf_mod289_3(i);
    vec4 p = _nf_perm(_nf_perm(_nf_perm(
             i.z + vec4(0.0, i1.z, i2.z, 1.0))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron
    float n_ = 0.142857142857; // 1.0/7.0
    vec3 ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    // Normalize gradients
    vec4 norm = _nf_tis(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w;

    // Mix contributions from the four corners
    vec4 m = max(0.5 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 105.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

// --- 4D Simplex noise ---
// Returns value in approx [-1, 1]

float simplexNoise4D(vec4 v) {
    const vec4 C = vec4(
        0.138196601125011,   // (5 - sqrt(5)) / 20
        0.276393202250021,   // 2 * (5 - sqrt(5)) / 20
        0.414589803375032,   // 3 * (5 - sqrt(5)) / 20
       -0.447213595499958    // -1 + 4 * C.x
    );
    const float F4 = 0.309016994374947; // (sqrt(5) - 1) / 4

    // First corner
    vec4 i  = floor(v + dot(v, vec4(F4)));
    vec4 x0 = v - i + dot(i, C.xxxx);

    // Rank sorting (determine simplex traversal order)
    vec4 i0;
    vec3 isX = step(x0.yzw, x0.xxx);
    vec3 isYZ = step(x0.zww, x0.yyz);
    i0.x = isX.x + isX.y + isX.z;
    i0.yzw = 1.0 - isX;
    i0.y += isYZ.x + isYZ.y;
    i0.zw += 1.0 - isYZ.xy;
    i0.z += isYZ.z;
    i0.w += 1.0 - isYZ.z;

    vec4 i3 = clamp(i0, 0.0, 1.0);
    vec4 i2 = clamp(i0 - 1.0, 0.0, 1.0);
    vec4 i1 = clamp(i0 - 2.0, 0.0, 1.0);

    vec4 x1 = x0 - i1 + C.xxxx;
    vec4 x2 = x0 - i2 + C.yyyy;
    vec4 x3 = x0 - i3 + C.zzzz;
    vec4 x4 = x0 + C.wwww;

    // Permutations
    i = _nf_mod289_4(i);
    float j0 = _nf_perm(vec4(_nf_perm(vec4(_nf_perm(vec4(_nf_perm(vec4(
        i.w)).x + i.z)).x + i.y)).x + i.x)).x;
    vec4 j1 = _nf_perm(_nf_perm(_nf_perm(_nf_perm(
        i.w + vec4(i1.w, i2.w, i3.w, 1.0))
      + i.z + vec4(i1.z, i2.z, i3.z, 1.0))
      + i.y + vec4(i1.y, i2.y, i3.y, 1.0))
      + i.x + vec4(i1.x, i2.x, i3.x, 1.0));

    // Gradients (using 5-point method mapped to 4D)
    vec4 ip = vec4(1.0 / 294.0, 1.0 / 49.0, 1.0 / 7.0, 0.0);

    vec4 p0_4d = _nf_mod289_4(floor(fract(vec4(j0) * ip) * 7.0)) * ip.z - 1.0;
    float d0 = 0.75 - dot(p0_4d, p0_4d);

    vec4 p1_4d = _nf_mod289_4(floor(fract(j1.xxxx * ip) * 7.0)) * ip.z - 1.0;
    float d1 = 0.75 - dot(p1_4d, p1_4d);

    vec4 p2_4d = _nf_mod289_4(floor(fract(j1.yyyy * ip) * 7.0)) * ip.z - 1.0;
    float d2 = 0.75 - dot(p2_4d, p2_4d);

    vec4 p3_4d = _nf_mod289_4(floor(fract(j1.zzzz * ip) * 7.0)) * ip.z - 1.0;
    float d3 = 0.75 - dot(p3_4d, p3_4d);

    vec4 p4_4d = _nf_mod289_4(floor(fract(j1.wwww * ip) * 7.0)) * ip.z - 1.0;
    float d4 = 0.75 - dot(p4_4d, p4_4d);

    // Radial falloff
    vec4 m0 = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    float m4_val = max(0.6 - dot(x4, x4), 0.0);
    m0 = m0 * m0;
    m4_val = m4_val * m4_val;

    return 49.0 * (
        dot(m0 * m0, vec4(dot(x0, p0_4d), dot(x1, p1_4d), dot(x2, p2_4d), dot(x3, p3_4d)))
      + m4_val * m4_val * dot(x4, p4_4d)
    );
}

#endif
