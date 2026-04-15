// examples/psychedelic_fullscreen.glsl
// Complete standalone fragment shader demonstrating iterative domain warp.
// Paste into ShaderToy, glslEditor, or any WebGL fragment shader sandbox.
//
// Usage: This shader maps UV coordinates through 3 layers of domain warp
// using FBM simplex noise, then maps the result to a trippy HSB color ramp.
//
// Uniforms expected:
//   uniform float u_time;
//   uniform vec2 u_resolution;

#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

// ---- Inline simplex noise (from noise_fields/shaders/glsl/simplex.glsl) ----

vec3 _mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 _mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 _perm(vec4 x) { return _mod289(((x * 34.0) + 10.0) * x); }

float snoise(vec3 v) {
    const vec2 C = vec2(1.0/6.0, 1.0/3.0);
    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - 0.5;
    i = _mod289(i);
    vec4 p = _perm(_perm(_perm(
             i.z + vec4(0.0, i1.z, i2.z, 1.0))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0));
    vec4 j = p - 49.0 * floor(p / 49.0);
    vec4 x_ = floor(j / 7.0);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    vec4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    vec3 g0 = vec3(a0.xy, h.x);
    vec3 g1 = vec3(a0.zw, h.y);
    vec3 g2 = vec3(a1.xy, h.z);
    vec3 g3 = vec3(a1.zw, h.w);
    vec4 norm = 1.79284291400159 - 0.85373472095314 *
        vec4(dot(g0,g0), dot(g1,g1), dot(g2,g2), dot(g3,g3));
    g0 *= norm.x; g1 *= norm.y; g2 *= norm.z; g3 *= norm.w;
    vec4 m = max(0.5 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 105.0 * dot(m*m, vec4(dot(g0,x0), dot(g1,x1), dot(g2,x2), dot(g3,x3)));
}

// ---- FBM ----

float fbm(vec3 p) {
    float sum = 0.0, amp = 1.0, freq = 1.0;
    for (int i = 0; i < 5; i++) {
        sum += amp * snoise(p * freq);
        freq *= 2.0;
        amp *= 0.5;
    }
    return sum;
}

// ---- Domain warp (IQ style) ----

float pattern(vec3 p) {
    vec3 q = vec3(
        fbm(p + vec3(0.0, 0.0, 0.0)),
        fbm(p + vec3(5.2, 1.3, 2.8)),
        0.0
    );
    vec3 r = vec3(
        fbm(p + 4.0 * q + vec3(1.7, 9.2, 0.0)),
        fbm(p + 4.0 * q + vec3(8.3, 2.8, 0.0)),
        0.0
    );
    return fbm(p + 4.0 * r);
}

// ---- HSB to RGB ----

vec3 hsb2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

// ---- Main ----

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    float t = u_time * 0.1;
    vec3 p = vec3(uv * 1.5, t);

    float n = pattern(p);

    // Map noise to trippy HSB color
    float hue = fract(n * 0.5 + t * 0.05);
    float sat = 0.7 + 0.3 * sin(n * 3.14159);
    float bri = 0.5 + 0.5 * n;

    vec3 color = hsb2rgb(vec3(hue, sat, bri));

    gl_FragColor = vec4(color, 1.0);
}
