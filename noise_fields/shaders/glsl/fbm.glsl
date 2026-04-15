// shaders/glsl/fbm.glsl
// Fractal Brownian Motion combinator over Perlin or Simplex base noise.
// Requires perlin.glsl and/or simplex.glsl to be included first.

#ifndef NOISE_FIELDS_FBM_GLSL
#define NOISE_FIELDS_FBM_GLSL

// --- 3D FBM variants ---

float fbmPerlin(vec3 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    for (int i = 0; i < octaves; ++i) {
        sum += amp * perlinNoise3D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

float fbmSimplex(vec3 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    for (int i = 0; i < octaves; ++i) {
        sum += amp * simplexNoise3D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

// --- 2D FBM variants ---

float fbmPerlin2D(vec2 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    for (int i = 0; i < octaves; ++i) {
        sum += amp * perlinNoise2D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

float fbmSimplex2D(vec2 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    for (int i = 0; i < octaves; ++i) {
        sum += amp * simplexNoise2D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

#endif
