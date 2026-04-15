// shaders/wgsl/gabor.wgsl
// Gabor Noise — WGSL port of the GLSL implementation.
// Sparse convolution of oriented Gabor kernels (Lagae et al. 2009).

fn _nf_gab_hash2(p: vec2<f32>) -> vec2<f32> {
    let q = vec2<f32>(dot(p, vec2<f32>(127.1, 311.7)), dot(p, vec2<f32>(269.5, 183.3)));
    return fract(sin(q) * 43758.5453123);
}

fn _nf_gaborKernel(d: vec2<f32>, freq: f32, angle: f32, bw: f32) -> f32 {
    let gaussian = exp(-3.14159265 * bw * bw * dot(d, d));
    let sinusoid = cos(2.0 * 3.14159265 * freq * (cos(angle) * d.x + sin(angle) * d.y));
    return gaussian * sinusoid;
}

// 2D Gabor Noise (isotropic / fixed orientation) — returns approx [-1, 1]
fn gaborNoise2D(p: vec2<f32>, freq: f32, angle: f32, bw: f32) -> f32 {
    let cell = floor(p);
    var result: f32 = 0.0;

    for (var dy: i32 = -2; dy <= 2; dy++) {
        for (var dx: i32 = -2; dx <= 2; dx++) {
            let neighbour = cell + vec2<f32>(f32(dx), f32(dy));
            let rnd = _nf_gab_hash2(neighbour);
            let kernelPos = neighbour + rnd;
            let d = p - kernelPos;
            result += _nf_gaborKernel(d, freq, angle, bw);
        }
    }
    return clamp(result, -1.0, 1.0);
}

// 2D Gabor Noise (anisotropic — per-axis Gaussian widths) — returns approx [-1, 1]
fn gaborNoiseAniso2D(p: vec2<f32>, freq: f32, angle: f32, bwX: f32, bwY: f32) -> f32 {
    let cell = floor(p);
    var result: f32 = 0.0;
    let cosA = cos(angle);
    let sinA = sin(angle);

    for (var dy: i32 = -2; dy <= 2; dy++) {
        for (var dx: i32 = -2; dx <= 2; dx++) {
            let neighbour = cell + vec2<f32>(f32(dx), f32(dy));
            let rnd = _nf_gab_hash2(neighbour);
            let kernelPos = neighbour + rnd;
            let d = p - kernelPos;
            let dLocal = vec2<f32>(cosA * d.x + sinA * d.y, -sinA * d.x + cosA * d.y);
            let gaussian = exp(-3.14159265 * (bwX * bwX * dLocal.x * dLocal.x +
                                              bwY * bwY * dLocal.y * dLocal.y));
            let sinusoid = cos(2.0 * 3.14159265 * freq * dLocal.x);
            result += gaussian * sinusoid;
        }
    }
    return clamp(result, -1.0, 1.0);
}

// 2D Gabor FBM
fn gaborFBM2D(p: vec2<f32>, freq: f32, angle: f32, bw: f32, octaves: i32, gain: f32) -> f32 {
    var value: f32 = 0.0;
    var amplitude: f32 = 0.5;
    var maxValue: f32 = 0.0;
    for (var i: i32 = 0; i < octaves; i++) {
        let a = angle + f32(i) * 0.37;
        value += amplitude * gaborNoise2D(p * pow(2.0, f32(i)), freq, a, bw);
        maxValue += amplitude;
        amplitude *= gain;
    }
    return value / maxValue;
}
