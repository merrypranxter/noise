// shaders/glsl/ridged_multifractal.glsl
// Ridged multifractal noise for jagged, mountainous structures.

#ifndef NOISE_FIELDS_RIDGED_MULTIFRACTAL_GLSL
#define NOISE_FIELDS_RIDGED_MULTIFRACTAL_GLSL

float ridgedMultifractal(vec3 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    float prev = 1.0;
    for (int i = 0; i < octaves; ++i) {
        float n = 1.0 - abs(perlinNoise(p * freq));
        n = n * n;
        sum += n * amp * prev;
        prev = n;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

#endif
