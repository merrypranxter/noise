// shaders/wgsl/fbm.wgsl
// Fractal Brownian Motion combinator over Perlin or Simplex base noise.

fn fbmPerlin3D(p : vec3<f32>, octaves : i32, baseFreq : f32, lacunarity : f32, gain : f32) -> f32 {
    var amp : f32 = 1.0;
    var freq : f32 = baseFreq;
    var sum : f32 = 0.0;
    for (var i : i32 = 0; i < octaves; i = i + 1) {
        sum = sum + amp * perlinNoise3D(p * freq);
        freq = freq * lacunarity;
        amp = amp * gain;
    }
    return sum;
}

fn fbmSimplex3D(p : vec3<f32>, octaves : i32, baseFreq : f32, lacunarity : f32, gain : f32) -> f32 {
    var amp : f32 = 1.0;
    var freq : f32 = baseFreq;
    var sum : f32 = 0.0;
    for (var i : i32 = 0; i < octaves; i = i + 1) {
        sum = sum + amp * simplexNoise3D(p * freq);
        freq = freq * lacunarity;
        amp = amp * gain;
    }
    return sum;
}
