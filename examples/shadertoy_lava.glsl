// examples/shadertoy_lava.glsl
// Lava crack shader for ShaderToy.
// Demonstrates: Worley F2-F1 + domain warp + black body color mapping.
//
// In ShaderToy, paste this as the Image shader. Uses iTime and iResolution.

// ---- Hash ----
vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

// ---- Worley F2-F1 ----
float worleyEdge(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float d1 = 8.0, d2 = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = hash22(n + g);
            // Animate feature points
            o = 0.5 + 0.5 * sin(iTime * 0.3 + 6.2831 * o);
            vec2 r = g + o - f;
            float d = dot(r, r);
            if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
        }
    }
    return sqrt(d2) - sqrt(d1);
}

// ---- Simplex 2D (compact) ----
float snoise2(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz; x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = mod(((i.y + vec3(0.0, i1.y, 1.0)) * 34.0 + 10.0) * (i.y + vec3(0.0, i1.y, 1.0)), 289.0);
    p = mod(((p + i.x + vec3(0.0, i1.x, 1.0)) * 34.0 + 10.0) * (p + i.x + vec3(0.0, i1.x, 1.0)), 289.0);
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m * m * m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 a0 = x - floor(x + 0.5);
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    return 130.0 * dot(m, vec3(a0.x * x0.x + h.x * x0.y, a0.y * x12.x + h.y * x12.y, a0.z * x12.z + h.z * x12.w));
}

// ---- Domain warp ----
vec2 warp(vec2 p, float strength) {
    return p + vec2(snoise2(p * 1.2), snoise2(p * 1.2 + vec2(5.2, 1.3))) * strength;
}

// ---- Black body approximation ----
vec3 blackBody(float t) {
    t = clamp(t, 0.0, 1.0);
    vec3 c = vec3(0.0);
    c.r = smoothstep(0.0, 0.4, t);
    c.g = smoothstep(0.2, 0.7, t) * 0.7;
    c.b = smoothstep(0.5, 1.0, t) * 0.3;
    return c * (0.5 + 1.5 * t);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // Scale and warp
    vec2 p = uv * 4.0;
    p = warp(p, 0.6);

    // Worley edge detection
    float edge = worleyEdge(p);

    // Sharpen and invert: thin bright cracks on dark rock
    float lava = pow(1.0 - edge, 5.0);

    // Color
    vec3 col = blackBody(lava);

    // Subtle rock texture in dark areas
    float rock = snoise2(uv * 8.0) * 0.03;
    col += vec3(rock) * (1.0 - lava);

    fragColor = vec4(col, 1.0);
}
