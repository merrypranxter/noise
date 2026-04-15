// shaders/wgsl/ridged_multifractal.wgsl
// Ridged multifractal noise for jagged, mountainous structures.
// Requires perlin.wgsl to be included first.

fn ridgedMultifractal(p: vec3<f32>, octaves: i32, baseFreq: f32, lacunarity: f32, gain: f32) -> f32 {
    var amp = 1.0;
    var freq = baseFreq;
    var sum = 0.0;
    var prev = 1.0;
    for (var i = 0; i < octaves; i++) {
        var n = 1.0 - abs(perlinNoise3D(p * freq));
        n = n * n;
        sum += n * amp * prev;
        prev = n;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

fn ridgedMultifractalSimplex(p: vec3<f32>, octaves: i32, baseFreq: f32, lacunarity: f32, gain: f32) -> f32 {
    var amp = 1.0;
    var freq = baseFreq;
    var sum = 0.0;
    var prev = 1.0;
    for (var i = 0; i < octaves; i++) {
        var n = 1.0 - abs(simplexNoise3D(p * freq));
        n = n * n;
        sum += n * amp * prev;
        prev = n;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}
