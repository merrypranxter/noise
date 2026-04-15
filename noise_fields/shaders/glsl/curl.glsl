// shaders/glsl/curl.glsl
// Curl noise: divergence-free vector field via finite differences of scalar noise.

#ifndef NOISE_FIELDS_CURL_GLSL
#define NOISE_FIELDS_CURL_GLSL

// 2D curl noise returning a vec2 velocity field
vec2 curlNoise2D(vec2 p, float stepSize) {
    float dx = simplexNoise(p + vec2(stepSize, 0.0)) - simplexNoise(p - vec2(stepSize, 0.0));
    float dy = simplexNoise(p + vec2(0.0, stepSize)) - simplexNoise(p - vec2(0.0, stepSize));
    return vec2(dy, -dx) / (2.0 * stepSize);
}

// 3D curl noise returning a vec3 velocity field
vec3 curlNoise3D(vec3 p, float stepSize) {
    vec3 dx = vec3(stepSize, 0.0, 0.0);
    vec3 dy = vec3(0.0, stepSize, 0.0);
    vec3 dz = vec3(0.0, 0.0, stepSize);

    float dFz_dy = simplexNoise(p + dy) - simplexNoise(p - dy);
    float dFy_dz = simplexNoise(p + dz) - simplexNoise(p - dz);
    float dFx_dz = simplexNoise(p + dz + vec3(31.416, 0.0, 0.0)) - simplexNoise(p - dz + vec3(31.416, 0.0, 0.0));
    float dFz_dx = simplexNoise(p + dx) - simplexNoise(p - dx);
    float dFy_dx = simplexNoise(p + dx + vec3(0.0, 31.416, 0.0)) - simplexNoise(p - dx + vec3(0.0, 31.416, 0.0));
    float dFx_dy = simplexNoise(p + dy + vec3(0.0, 0.0, 31.416)) - simplexNoise(p - dy + vec3(0.0, 0.0, 31.416));

    return vec3(
        dFz_dy - dFy_dz,
        dFx_dz - dFz_dx,
        dFy_dx - dFx_dy
    ) / (2.0 * stepSize);
}

#endif
