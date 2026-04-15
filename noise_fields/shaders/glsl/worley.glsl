// shaders/glsl/worley.glsl
// Worley (cellular) noise, 2D/3D variants.
// Adapted from canonical implementations (e.g., Stefan Gustavson's cellular noise).

#ifndef NOISE_FIELDS_WORLEY_GLSL
#define NOISE_FIELDS_WORLEY_GLSL

// 2D Worley noise returning F1 distance
float worleyF1_2D(vec2 p);

// 2D Worley noise returning F2 distance
float worleyF2_2D(vec2 p);

// 2D Worley noise returning F2 - F1 (cell edge detection)
float worleyF2minusF1_2D(vec2 p);

// 3D Worley noise returning F1 distance
float worleyF1_3D(vec3 p);

// 3D Worley noise returning F2 - F1
float worleyF2minusF1_3D(vec3 p);

#endif
