// shaders/glsl/gabor.glsl
// Gabor Noise — sparse convolution of oriented Gabor kernels.
// Based on Lagae et al. 2009 "A Procedural Texture Atlas".
// Anisotropic: oriented sinusoid windowed by a Gaussian envelope.

#ifndef NOISE_FIELDS_GABOR_GLSL
#define NOISE_FIELDS_GABOR_GLSL

// --- Internal helpers ---

// 2D hash returning a value in [0, 1)
vec2 _nf_gab_hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123);
}

float _nf_gab_hash1(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Single isotropic Gabor kernel evaluated at offset d
// freq: spatial frequency of the sinusoid
// angle: orientation in radians
// bw: Gaussian half-width (bandwidth)
float _nf_gaborKernel(vec2 d, float freq, float angle, float bw) {
    float gaussian = exp(-3.14159265 * bw * bw * dot(d, d));
    float sinusoid = cos(2.0 * 3.14159265 * freq * (cos(angle) * d.x + sin(angle) * d.y));
    return gaussian * sinusoid;
}

// --- 2D Gabor Noise (isotropic / fixed orientation) ---
// p:     sample position
// freq:  sinusoid frequency (try 3.0 – 8.0)
// angle: orientation in radians (0 = horizontal)
// bw:    Gaussian bandwidth (try 0.8 – 2.5)
// Returns value in approx [-1, 1]

float gaborNoise2D(vec2 p, float freq, float angle, float bw) {
    vec2 cell = floor(p);
    float result = 0.0;

    for (int dy = -2; dy <= 2; dy++) {
        for (int dx = -2; dx <= 2; dx++) {
            vec2 neighbour = cell + vec2(float(dx), float(dy));
            vec2 rnd = _nf_gab_hash2(neighbour);
            vec2 kernelPos = neighbour + rnd;   // jittered kernel centre
            vec2 d = p - kernelPos;
            result += _nf_gaborKernel(d, freq, angle, bw);
        }
    }
    return clamp(result, -1.0, 1.0);
}

// --- 2D Gabor Noise (anisotropic — per-axis Gaussian widths) ---
// bwX, bwY: independent Gaussian widths before rotation
// Returns value in approx [-1, 1]

float gaborNoiseAniso2D(vec2 p, float freq, float angle, float bwX, float bwY) {
    vec2 cell = floor(p);
    float result = 0.0;
    float cosA = cos(angle);
    float sinA = sin(angle);

    for (int dy = -2; dy <= 2; dy++) {
        for (int dx = -2; dx <= 2; dx++) {
            vec2 neighbour = cell + vec2(float(dx), float(dy));
            vec2 rnd = _nf_gab_hash2(neighbour);
            vec2 kernelPos = neighbour + rnd;
            vec2 d = p - kernelPos;

            // Rotate offset into kernel-local space
            vec2 dLocal = vec2(cosA * d.x + sinA * d.y, -sinA * d.x + cosA * d.y);
            float gaussian = exp(-3.14159265 * (bwX * bwX * dLocal.x * dLocal.x +
                                                bwY * bwY * dLocal.y * dLocal.y));
            float sinusoid = cos(2.0 * 3.14159265 * freq * dLocal.x);
            result += gaussian * sinusoid;
        }
    }
    return clamp(result, -1.0, 1.0);
}

// --- 2D Gabor FBM ---
// Stacks octaves of gaborNoise2D, rotating orientation slightly each octave

float gaborFBM2D(vec2 p, float freq, float angle, float bw, int octaves, float gain) {
    float value = 0.0;
    float amplitude = 0.5;
    float maxValue = 0.0;
    for (int i = 0; i < octaves; i++) {
        float a = angle + float(i) * 0.37;  // rotate per octave to break alignment
        value += amplitude * gaborNoise2D(p * pow(2.0, float(i)), freq, a, bw);
        maxValue += amplitude;
        amplitude *= gain;
    }
    return value / maxValue;
}

#endif
