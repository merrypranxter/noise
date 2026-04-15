// shaders/wgsl/value.wgsl
// Value noise, 2D and 3D variants + FBM wrapper.
// WGSL port — standalone fn definitions, no module syntax.

fn _nf_val_hash2(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453123);
}

fn _nf_val_hash3(p: vec3<f32>) -> f32 {
    return fract(sin(dot(p, vec3<f32>(127.1, 311.7, 74.7))) * 43758.5453123);
}

fn _nf_val_fade2(t: vec2<f32>) -> vec2<f32> {
    return t * t * t * (t * (t * 6.0 - vec2<f32>(15.0)) + vec2<f32>(10.0));
}

fn _nf_val_fade3(t: vec3<f32>) -> vec3<f32> {
    return t * t * t * (t * (t * 6.0 - vec3<f32>(15.0)) + vec3<f32>(10.0));
}

// 2D Value Noise — returns approx [-1, 1]
fn valueNoise2D(p: vec2<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = _nf_val_fade2(f);

    let a = _nf_val_hash2(i + vec2<f32>(0.0, 0.0));
    let b = _nf_val_hash2(i + vec2<f32>(1.0, 0.0));
    let c = _nf_val_hash2(i + vec2<f32>(0.0, 1.0));
    let d = _nf_val_hash2(i + vec2<f32>(1.0, 1.0));

    let v = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
    return v * 2.0 - 1.0;
}

// 3D Value Noise — returns approx [-1, 1]
fn valueNoise3D(p: vec3<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = _nf_val_fade3(f);

    let n000 = _nf_val_hash3(i + vec3<f32>(0.0, 0.0, 0.0));
    let n100 = _nf_val_hash3(i + vec3<f32>(1.0, 0.0, 0.0));
    let n010 = _nf_val_hash3(i + vec3<f32>(0.0, 1.0, 0.0));
    let n110 = _nf_val_hash3(i + vec3<f32>(1.0, 1.0, 0.0));
    let n001 = _nf_val_hash3(i + vec3<f32>(0.0, 0.0, 1.0));
    let n101 = _nf_val_hash3(i + vec3<f32>(1.0, 0.0, 1.0));
    let n011 = _nf_val_hash3(i + vec3<f32>(0.0, 1.0, 1.0));
    let n111 = _nf_val_hash3(i + vec3<f32>(1.0, 1.0, 1.0));

    let v = mix(
        mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
        mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
        u.z
    );
    return v * 2.0 - 1.0;
}

// 2D Value FBM
fn valueFBM2D(p: vec2<f32>, octaves: i32, lacunarity: f32, gain: f32) -> f32 {
    var value: f32 = 0.0;
    var amplitude: f32 = 0.5;
    var frequency: f32 = 1.0;
    var maxValue: f32 = 0.0;
    for (var i: i32 = 0; i < octaves; i++) {
        value += amplitude * valueNoise2D(p * frequency);
        maxValue += amplitude;
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return value / maxValue;
}
