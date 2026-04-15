// shaders/wgsl/perlin.wgsl
// Perlin gradient noise, 2D/3D variants.
// WGSL port of the GLSL canonical implementation.

fn _nf_mod289_2(x: vec2<f32>) -> vec2<f32> { return x - floor(x * (1.0 / 289.0)) * 289.0; }
fn _nf_mod289_3(x: vec3<f32>) -> vec3<f32> { return x - floor(x * (1.0 / 289.0)) * 289.0; }
fn _nf_mod289_4(x: vec4<f32>) -> vec4<f32> { return x - floor(x * (1.0 / 289.0)) * 289.0; }

fn _nf_permute_4(x: vec4<f32>) -> vec4<f32> { return _nf_mod289_4(((x * 34.0) + vec4<f32>(10.0)) * x); }

fn _nf_taylorInvSqrt_4(r: vec4<f32>) -> vec4<f32> { return vec4<f32>(1.79284291400159) - r * 0.85373472095314; }

fn _nf_fade_2(t: vec2<f32>) -> vec2<f32> { return t * t * t * (t * (t * 6.0 - vec2<f32>(15.0)) + vec2<f32>(10.0)); }
fn _nf_fade_3(t: vec3<f32>) -> vec3<f32> { return t * t * t * (t * (t * 6.0 - vec3<f32>(15.0)) + vec3<f32>(10.0)); }

fn perlinNoise2D(P: vec2<f32>) -> f32 {
    var Pi = floor(vec4<f32>(P.x, P.y, P.x, P.y)) + vec4<f32>(0.0, 0.0, 1.0, 1.0);
    let Pf = fract(vec4<f32>(P.x, P.y, P.x, P.y)) - vec4<f32>(0.0, 0.0, 1.0, 1.0);
    Pi = _nf_mod289_4(Pi);
    let ix = vec4<f32>(Pi.x, Pi.z, Pi.x, Pi.z);
    let iy = vec4<f32>(Pi.y, Pi.y, Pi.w, Pi.w);
    let fx = vec4<f32>(Pf.x, Pf.z, Pf.x, Pf.z);
    let fy = vec4<f32>(Pf.y, Pf.y, Pf.w, Pf.w);

    let i = _nf_permute_4(_nf_permute_4(ix) + iy);

    var gx = fract(i * (1.0 / 41.0)) * 2.0 - vec4<f32>(1.0);
    let gy_v = abs(gx) - vec4<f32>(0.5);
    let tx = floor(gx + vec4<f32>(0.5));
    gx = gx - tx;

    let g00 = vec2<f32>(gx.x, gy_v.x);
    let g10 = vec2<f32>(gx.y, gy_v.y);
    let g01 = vec2<f32>(gx.z, gy_v.z);
    let g11 = vec2<f32>(gx.w, gy_v.w);

    let norm = _nf_taylorInvSqrt_4(vec4<f32>(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));

    let n00 = dot(g00 * norm.x, vec2<f32>(fx.x, fy.x));
    let n10 = dot(g10 * norm.z, vec2<f32>(fx.y, fy.y));
    let n01 = dot(g01 * norm.y, vec2<f32>(fx.z, fy.z));
    let n11 = dot(g11 * norm.w, vec2<f32>(fx.w, fy.w));

    let fade_xy = _nf_fade_2(vec2<f32>(Pf.x, Pf.y));
    let n_x = mix(vec2<f32>(n00, n01), vec2<f32>(n10, n11), vec2<f32>(fade_xy.x));
    let n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

fn perlinNoise3D(P: vec3<f32>) -> f32 {
    let Pi0 = _nf_mod289_3(floor(P));
    let Pi1 = _nf_mod289_3(Pi0 + vec3<f32>(1.0));
    let Pf0 = fract(P);
    let Pf1 = Pf0 - vec3<f32>(1.0);

    let ix = vec4<f32>(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    let iy = vec4<f32>(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
    let iz0 = vec4<f32>(Pi0.z, Pi0.z, Pi0.z, Pi0.z);
    let iz1 = vec4<f32>(Pi1.z, Pi1.z, Pi1.z, Pi1.z);

    let ixy = _nf_permute_4(_nf_permute_4(ix) + iy);
    let ixy0 = _nf_permute_4(ixy + iz0);
    let ixy1 = _nf_permute_4(ixy + iz1);

    var gx0 = ixy0 * (1.0 / 7.0);
    var gy0 = fract(floor(gx0) * (1.0 / 7.0)) - vec4<f32>(0.5);
    gx0 = fract(gx0);
    var gz0 = vec4<f32>(0.5) - abs(gx0) - abs(gy0);
    let sz0 = step(gz0, vec4<f32>(0.0));
    gx0 = gx0 - sz0 * (step(vec4<f32>(0.0), gx0) - vec4<f32>(0.5));
    gy0 = gy0 - sz0 * (step(vec4<f32>(0.0), gy0) - vec4<f32>(0.5));

    var gx1 = ixy1 * (1.0 / 7.0);
    var gy1 = fract(floor(gx1) * (1.0 / 7.0)) - vec4<f32>(0.5);
    gx1 = fract(gx1);
    var gz1 = vec4<f32>(0.5) - abs(gx1) - abs(gy1);
    let sz1 = step(gz1, vec4<f32>(0.0));
    gx1 = gx1 - sz1 * (step(vec4<f32>(0.0), gx1) - vec4<f32>(0.5));
    gy1 = gy1 - sz1 * (step(vec4<f32>(0.0), gy1) - vec4<f32>(0.5));

    let g000 = vec3<f32>(gx0.x, gy0.x, gz0.x);
    let g100 = vec3<f32>(gx0.y, gy0.y, gz0.y);
    let g010 = vec3<f32>(gx0.z, gy0.z, gz0.z);
    let g110 = vec3<f32>(gx0.w, gy0.w, gz0.w);
    let g001 = vec3<f32>(gx1.x, gy1.x, gz1.x);
    let g101 = vec3<f32>(gx1.y, gy1.y, gz1.y);
    let g011 = vec3<f32>(gx1.z, gy1.z, gz1.z);
    let g111 = vec3<f32>(gx1.w, gy1.w, gz1.w);

    let norm0 = _nf_taylorInvSqrt_4(vec4<f32>(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    let norm1 = _nf_taylorInvSqrt_4(vec4<f32>(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));

    let n000 = dot(g000 * norm0.x, Pf0);
    let n100 = dot(g100 * norm0.z, vec3<f32>(Pf1.x, Pf0.y, Pf0.z));
    let n010 = dot(g010 * norm0.y, vec3<f32>(Pf0.x, Pf1.y, Pf0.z));
    let n110 = dot(g110 * norm0.w, vec3<f32>(Pf1.x, Pf1.y, Pf0.z));
    let n001 = dot(g001 * norm1.x, vec3<f32>(Pf0.x, Pf0.y, Pf1.z));
    let n101 = dot(g101 * norm1.z, vec3<f32>(Pf1.x, Pf0.y, Pf1.z));
    let n011 = dot(g011 * norm1.y, vec3<f32>(Pf0.x, Pf1.y, Pf1.z));
    let n111 = dot(g111 * norm1.w, Pf1);

    let fade_xyz = _nf_fade_3(Pf0);
    let n_z = mix(vec4<f32>(n000, n100, n010, n110), vec4<f32>(n001, n101, n011, n111), vec4<f32>(fade_xyz.z));
    let n_yz = mix(vec2<f32>(n_z.x, n_z.z), vec2<f32>(n_z.y, n_z.w), vec2<f32>(fade_xyz.y));
    let n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}
