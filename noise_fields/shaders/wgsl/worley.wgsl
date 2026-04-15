// shaders/wgsl/worley.wgsl
// Worley (cellular) noise, 2D/3D variants.
// Adapted from canonical implementations for WGSL.

fn worleyF1_2D(p : vec2<f32>) -> f32;
fn worleyF2_2D(p : vec2<f32>) -> f32;
fn worleyF2minusF1_2D(p : vec2<f32>) -> f32;

fn worleyF1_3D(p : vec3<f32>) -> f32;
fn worleyF2minusF1_3D(p : vec3<f32>) -> f32;
