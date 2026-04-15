// shaders/wgsl/fbm.wgsl
// Fractal Brownian Motion combinator over Perlin or Simplex base noise.
// Requires perlin.wgsl or simplex.wgsl to be included first.

fn fbmPerlin(p: vec3<f32>, octaves: i32, baseFreq: f32, lacunarity: f32, gain: f32) -> f32 {
    var amp = 1.0;
    var freq = baseFreq;
    var sum = 0.0;
    for (var i = 0; i < octaves; i++) {
        sum += amp * perlinNoise3D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

fn fbmSimplex(p: vec3<f32>, octaves: i32, baseFreq: f32, lacunarity: f32, gain: f32) -> f32 {
    var amp = 1.0;
    var freq = baseFreq;
    var sum = 0.0;
    for (var i = 0; i < octaves; i++) {
        sum += amp * simplexNoise3D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

fn fbmPerlin2D(p: vec2<f32>, octaves: i32, baseFreq: f32, lacunarity: f32, gain: f32) -> f32 {
    var amp = 1.0;
    var freq = baseFreq;
    var sum = 0.0;
    for (var i = 0; i < octaves; i++) {
        sum += amp * perlinNoise2D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

fn fbmSimplex2D(p: vec2<f32>, octaves: i32, baseFreq: f32, lacunarity: f32, gain: f32) -> f32 {
    var amp = 1.0;
    var freq = baseFreq;
    var sum = 0.0;
    for (var i = 0; i < octaves; i++) {
        sum += amp * simplexNoise2D(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}
