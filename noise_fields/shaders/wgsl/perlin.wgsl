// shaders/wgsl/perlin.wgsl
// Perlin gradient noise, 2D/3D variants.
// Adapted from canonical implementations for WGSL.

fn perlinNoise2D(p : vec2<f32>) -> f32;
fn perlinNoise3D(p : vec3<f32>) -> f32;
