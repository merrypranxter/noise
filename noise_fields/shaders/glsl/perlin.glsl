// shaders/glsl/perlin.glsl
// Perlin gradient noise, 2D/3D variants.
// Adapted from canonical implementations (e.g., stegu/webgl-noise, Patricio Gonzalez Vivo).

#ifndef NOISE_FIELDS_PERLIN_GLSL
#define NOISE_FIELDS_PERLIN_GLSL

// 2D Perlin noise
float perlinNoise2D(vec2 p);

// 3D Perlin noise
float perlinNoise3D(vec3 p);

#endif
