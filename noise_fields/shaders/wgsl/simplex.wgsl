// shaders/wgsl/simplex.wgsl
// Simplex gradient noise, 2D/3D variants.
// WGSL port based on Ashima Arts / Stefan Gustavson.

fn _snf_mod289_2(x: vec2<f32>) -> vec2<f32> { return x - floor(x * (1.0 / 289.0)) * 289.0; }
fn _snf_mod289_3(x: vec3<f32>) -> vec3<f32> { return x - floor(x * (1.0 / 289.0)) * 289.0; }
fn _snf_mod289_4(x: vec4<f32>) -> vec4<f32> { return x - floor(x * (1.0 / 289.0)) * 289.0; }
fn _snf_perm3(x: vec3<f32>) -> vec3<f32> { return _snf_mod289_3(((x * 34.0) + vec3<f32>(10.0)) * x); }
fn _snf_perm4(x: vec4<f32>) -> vec4<f32> { return _snf_mod289_4(((x * 34.0) + vec4<f32>(10.0)) * x); }
fn _snf_tis(r: vec4<f32>) -> vec4<f32> { return vec4<f32>(1.79284291400159) - r * 0.85373472095314; }

fn simplexNoise2D(v: vec2<f32>) -> f32 {
    let C = vec4<f32>(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);

    let i = floor(v + vec2<f32>(dot(v, vec2<f32>(C.y))));
    let x0 = v - i + vec2<f32>(dot(i, vec2<f32>(C.x)));

    var i1: vec2<f32>;
    if (x0.x > x0.y) { i1 = vec2<f32>(1.0, 0.0); } else { i1 = vec2<f32>(0.0, 1.0); }
    var x12 = vec4<f32>(x0.x, x0.y, x0.x, x0.y) + vec4<f32>(C.x, C.x, C.z, C.z);
    x12 = vec4<f32>(x12.x - i1.x, x12.y - i1.y, x12.z, x12.w);

    let ii = _snf_mod289_2(i);
    let p = _snf_perm3(_snf_perm3(ii.y + vec3<f32>(0.0, i1.y, 1.0)) + ii.x + vec3<f32>(0.0, i1.x, 1.0));

    var m = max(vec3<f32>(0.5) - vec3<f32>(dot(x0, x0), dot(vec2<f32>(x12.x, x12.y), vec2<f32>(x12.x, x12.y)), dot(vec2<f32>(x12.z, x12.w), vec2<f32>(x12.z, x12.w))), vec3<f32>(0.0));
    m = m * m;
    m = m * m;

    let x_g = 2.0 * fract(p * vec3<f32>(C.w)) - vec3<f32>(1.0);
    let h = abs(x_g) - vec3<f32>(0.5);
    let ox = floor(x_g + vec3<f32>(0.5));
    let a0 = x_g - ox;

    m = m * _snf_tis(vec4<f32>(a0.x * a0.x + h.x * h.x, a0.y * a0.y + h.y * h.y, a0.z * a0.z + h.z * h.z, 0.0)).xyz;

    let g0 = a0.x * x0.x + h.x * x0.y;
    let g1 = a0.y * x12.x + h.y * x12.y;
    let g2 = a0.z * x12.z + h.z * x12.w;

    return 130.0 * dot(m, vec3<f32>(g0, g1, g2));
}

fn simplexNoise3D(v: vec3<f32>) -> f32 {
    let C = vec2<f32>(1.0 / 6.0, 1.0 / 3.0);

    let i = floor(v + vec3<f32>(dot(v, vec3<f32>(C.y))));
    let x0 = v - i + vec3<f32>(dot(i, vec3<f32>(C.x)));

    let g = step(x0.yzx, x0.xyz);
    let l = vec3<f32>(1.0) - g;
    let i1 = min(g.xyz, l.zxy);
    let i2 = max(g.xyz, l.zxy);

    let x1 = x0 - i1 + vec3<f32>(C.x);
    let x2 = x0 - i2 + vec3<f32>(C.y);
    let x3 = x0 - vec3<f32>(0.5);

    let ii = _snf_mod289_3(i);
    let p = _snf_perm4(_snf_perm4(_snf_perm4(
        ii.z + vec4<f32>(0.0, i1.z, i2.z, 1.0))
      + ii.y + vec4<f32>(0.0, i1.y, i2.y, 1.0))
      + ii.x + vec4<f32>(0.0, i1.x, i2.x, 1.0));

    let n_ = 0.142857142857;
    let ns = n_ * vec3<f32>(2.0, 0.0, 1.0) - vec3<f32>(0.0, 1.0, 0.0) * 0.5;

    let j = p - 49.0 * floor(p * ns.z * ns.z);
    let x_ = floor(j * ns.z);
    let y_ = floor(j - 7.0 * x_);

    let x_grad = x_ * ns.x + vec4<f32>(ns.y);
    let y_grad = y_ * ns.x + vec4<f32>(ns.y);
    let h = vec4<f32>(1.0) - abs(x_grad) - abs(y_grad);

    let b0 = vec4<f32>(x_grad.x, x_grad.y, y_grad.x, y_grad.y);
    let b1 = vec4<f32>(x_grad.z, x_grad.w, y_grad.z, y_grad.w);

    let s0 = floor(b0) * 2.0 + vec4<f32>(1.0);
    let s1 = floor(b1) * 2.0 + vec4<f32>(1.0);
    let sh = -step(h, vec4<f32>(0.0));

    let a0 = vec4<f32>(b0.x, b0.z, b0.y, b0.w) + vec4<f32>(s0.x, s0.z, s0.y, s0.w) * vec4<f32>(sh.x, sh.x, sh.y, sh.y);
    let a1 = vec4<f32>(b1.x, b1.z, b1.y, b1.w) + vec4<f32>(s1.x, s1.z, s1.y, s1.w) * vec4<f32>(sh.z, sh.z, sh.w, sh.w);

    var p0 = vec3<f32>(a0.x, a0.y, h.x);
    var p1 = vec3<f32>(a0.z, a0.w, h.y);
    var p2 = vec3<f32>(a1.x, a1.y, h.z);
    var p3 = vec3<f32>(a1.z, a1.w, h.w);

    let norm = _snf_tis(vec4<f32>(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 = p0 * norm.x; p1 = p1 * norm.y; p2 = p2 * norm.z; p3 = p3 * norm.w;

    var m = max(vec4<f32>(0.5) - vec4<f32>(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), vec4<f32>(0.0));
    m = m * m;
    return 105.0 * dot(m * m, vec4<f32>(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}
