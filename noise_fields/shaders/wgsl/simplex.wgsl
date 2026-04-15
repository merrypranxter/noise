// shaders/wgsl/simplex.wgsl
// Simplex gradient noise, 2D/3D/4D variants.
// Adapted from canonical implementations for WGSL.

fn simplexNoise2D(p : vec2<f32>) -> f32;
fn simplexNoise3D(p : vec3<f32>) -> f32;
fn simplexNoise4D(p : vec4<f32>) -> f32;
