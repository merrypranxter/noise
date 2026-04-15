// shaders/glsl/domain_warp.glsl
// Domain warp utility: distort coordinates using a warp noise before sampling base noise.
// Requires simplex.glsl to be included first.

#ifndef NOISE_FIELDS_DOMAIN_WARP_GLSL
#define NOISE_FIELDS_DOMAIN_WARP_GLSL

// Warp 2D coordinates using simplex noise
vec2 domainWarp2D(vec2 p, float warpStrength, float warpFreq) {
    return p + vec2(
        simplexNoise2D(p * warpFreq),
        simplexNoise2D(p * warpFreq + vec2(5.2, 1.3))
    ) * warpStrength;
}

// Warp 3D coordinates using simplex noise
vec3 domainWarp3D(vec3 p, float warpStrength, float warpFreq) {
    return p + vec3(
        simplexNoise3D(p * warpFreq),
        simplexNoise3D(p * warpFreq + vec3(5.2, 1.3, 9.7)),
        simplexNoise3D(p * warpFreq + vec3(2.8, 7.1, 4.6))
    ) * warpStrength;
}

// Iterative domain warp for deeper psychedelic distortion
// f(p) = noise( p + noise( p + noise( p ) ) )
vec2 domainWarpIterative2D(vec2 p, float warpStrength, float warpFreq, int iterations) {
    vec2 q = p;
    for (int i = 0; i < iterations; ++i) {
        q = domainWarp2D(q, warpStrength, warpFreq);
    }
    return q;
}

vec3 domainWarpIterative3D(vec3 p, float warpStrength, float warpFreq, int iterations) {
    vec3 q = p;
    for (int i = 0; i < iterations; ++i) {
        q = domainWarp3D(q, warpStrength, warpFreq);
    }
    return q;
}

// IQ-style domain warp: uses different offsets per warp layer for richer patterns
vec2 domainWarpIQ2D(vec2 p, float warpStrength) {
    vec2 q = vec2(
        simplexNoise2D(p + vec2(0.0, 0.0)),
        simplexNoise2D(p + vec2(5.2, 1.3))
    );
    vec2 r = vec2(
        simplexNoise2D(p + warpStrength * q + vec2(1.7, 9.2)),
        simplexNoise2D(p + warpStrength * q + vec2(8.3, 2.8))
    );
    return p + warpStrength * r;
}

#endif
