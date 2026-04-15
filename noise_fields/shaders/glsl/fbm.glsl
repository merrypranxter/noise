// shaders/glsl/fbm.glsl
// Fractal Brownian Motion combinator over Perlin or Simplex base noise.

#ifndef NOISE_FIELDS_FBM_GLSL
#define NOISE_FIELDS_FBM_GLSL

float fbmPerlin(vec3 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    for (int i = 0; i < octaves; ++i) {
        sum += amp * perlinNoise(p * freq);
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
        sum += amp * simplexNoise(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

#endif
