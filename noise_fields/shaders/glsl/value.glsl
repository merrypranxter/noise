// shaders/glsl/value.glsl
// Value noise, 2D and 3D variants + FBM wrapper.
// Assigns pseudo-random scalars to lattice corners and interpolates
// with a C2 quintic smoothstep. Cheaper than Perlin noise.

#ifndef NOISE_FIELDS_VALUE_GLSL
#define NOISE_FIELDS_VALUE_GLSL

// --- Internal helpers ---

float _nf_val_hash1(float n) {
    return fract(sin(n) * 43758.5453123);
}

float _nf_val_hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float _nf_val_hash3(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

// Quintic smoothstep (Ken Perlin's C2 fade curve)
vec2 _nf_val_fade2(vec2 t) { return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); }
vec3 _nf_val_fade3(vec3 t) { return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); }

// --- 2D Value Noise ---
// Returns value in approx [-1, 1]

float valueNoise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = _nf_val_fade2(f);

    float a = _nf_val_hash2(i + vec2(0.0, 0.0));
    float b = _nf_val_hash2(i + vec2(1.0, 0.0));
    float c = _nf_val_hash2(i + vec2(0.0, 1.0));
    float d = _nf_val_hash2(i + vec2(1.0, 1.0));

    float v = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
    return v * 2.0 - 1.0;  // remap [0,1] -> [-1,1]
}

// --- 3D Value Noise ---
// Returns value in approx [-1, 1]

float valueNoise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = _nf_val_fade3(f);

    float n000 = _nf_val_hash3(i + vec3(0.0, 0.0, 0.0));
    float n100 = _nf_val_hash3(i + vec3(1.0, 0.0, 0.0));
    float n010 = _nf_val_hash3(i + vec3(0.0, 1.0, 0.0));
    float n110 = _nf_val_hash3(i + vec3(1.0, 1.0, 0.0));
    float n001 = _nf_val_hash3(i + vec3(0.0, 0.0, 1.0));
    float n101 = _nf_val_hash3(i + vec3(1.0, 0.0, 1.0));
    float n011 = _nf_val_hash3(i + vec3(0.0, 1.0, 1.0));
    float n111 = _nf_val_hash3(i + vec3(1.0, 1.0, 1.0));

    float v = mix(
        mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
        mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
        u.z
    );
    return v * 2.0 - 1.0;  // remap [0,1] -> [-1,1]
}

// --- 2D Value FBM ---
// octaves: number of octaves (typically 4-8)
// lacunarity: frequency multiplier per octave (typically 2.0)
// gain: amplitude multiplier per octave (typically 0.5)

float valueFBM2D(vec2 p, int octaves, float lacunarity, float gain) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float maxValue = 0.0;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * valueNoise2D(p * frequency);
        maxValue += amplitude;
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return value / maxValue;
}

#endif
