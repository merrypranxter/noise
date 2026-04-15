// shaders/glsl/simplex.glsl
// Simplex gradient noise, 2D/3D/4D variants.
// Adapted from canonical implementations (e.g., stegu/webgl-noise, Ashima Arts).

#ifndef NOISE_FIELDS_SIMPLEX_GLSL
#define NOISE_FIELDS_SIMPLEX_GLSL

// 2D Simplex noise
float simplexNoise2D(vec2 p);

// 3D Simplex noise
float simplexNoise3D(vec3 p);

// 4D Simplex noise
float simplexNoise4D(vec4 p);

#endif
