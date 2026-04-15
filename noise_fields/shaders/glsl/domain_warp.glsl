// shaders/glsl/domain_warp.glsl
// Domain warp utility: distort coordinates using a warp noise before sampling base noise.

#ifndef NOISE_FIELDS_DOMAIN_WARP_GLSL
#define NOISE_FIELDS_DOMAIN_WARP_GLSL

// Warp 2D coordinates using simplex noise
vec2 domainWarp2D(vec2 p, float warpStrength, float warpFreq) {
    return p + vec2(
        simplexNoise(p * warpFreq),
        simplexNoise(p * warpFreq + vec2(5.2, 1.3))
    ) * warpStrength;
}

// Warp 3D coordinates using simplex noise
vec3 domainWarp3D(vec3 p, float warpStrength, float warpFreq) {
    return p + vec3(
        simplexNoise(p * warpFreq),
        simplexNoise(p * warpFreq + vec3(5.2, 1.3, 9.7)),
        simplexNoise(p * warpFreq + vec3(2.8, 7.1, 4.6))
    ) * warpStrength;
}

#endif
