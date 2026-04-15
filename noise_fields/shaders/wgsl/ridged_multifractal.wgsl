// shaders/wgsl/ridged_multifractal.wgsl
// Ridged multifractal noise for jagged, mountainous structures.

fn ridgedMultifractal3D(p : vec3<f32>, octaves : i32, baseFreq : f32, lacunarity : f32, gain : f32) -> f32 {
    var amp : f32 = 1.0;
    var freq : f32 = baseFreq;
    var sum : f32 = 0.0;
    var prev : f32 = 1.0;
    for (var i : i32 = 0; i < octaves; i = i + 1) {
        var n : f32 = 1.0 - abs(perlinNoise3D(p * freq));
        n = n * n;
        sum = sum + n * amp * prev;
        prev = n;
        freq = freq * lacunarity;
        amp = amp * gain;
    }
    return sum;
}
