// shaders/wgsl/worley.wgsl
// Worley (cellular) noise, 2D/3D variants.
// WGSL port based on Stefan Gustavson / IQ implementations.

fn _wnf_hash2(p: vec2<f32>) -> vec2<f32> {
    let k = vec2<f32>(dot(p, vec2<f32>(127.1, 311.7)), dot(p, vec2<f32>(269.5, 183.3)));
    return fract(sin(k) * 43758.5453);
}

fn _wnf_hash3(p: vec3<f32>) -> vec3<f32> {
    let k = vec3<f32>(
        dot(p, vec3<f32>(127.1, 311.7, 74.7)),
        dot(p, vec3<f32>(269.5, 183.3, 246.1)),
        dot(p, vec3<f32>(113.5, 271.9, 124.6))
    );
    return fract(sin(k) * 43758.5453123);
}

fn _wnf_worley2D(p: vec2<f32>) -> vec2<f32> {
    let n = floor(p);
    let f = fract(p);
    var d1 = 8.0;
    var d2 = 8.0;
    for (var j = -1; j <= 1; j++) {
        for (var i = -1; i <= 1; i++) {
            let g = vec2<f32>(f32(i), f32(j));
            let o = _wnf_hash2(n + g);
            let r = g + o - f;
            let d = dot(r, r);
            if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
        }
    }
    return sqrt(vec2<f32>(d1, d2));
}

fn worleyF1_2D(p: vec2<f32>) -> f32 { return _wnf_worley2D(p).x; }
fn worleyF2_2D(p: vec2<f32>) -> f32 { return _wnf_worley2D(p).y; }
fn worleyF2minusF1_2D(p: vec2<f32>) -> f32 { let f = _wnf_worley2D(p); return f.y - f.x; }

fn _wnf_worley3D(p: vec3<f32>) -> vec2<f32> {
    let n = floor(p);
    let f = fract(p);
    var d1 = 8.0;
    var d2 = 8.0;
    for (var k = -1; k <= 1; k++) {
        for (var j = -1; j <= 1; j++) {
            for (var i = -1; i <= 1; i++) {
                let g = vec3<f32>(f32(i), f32(j), f32(k));
                let o = _wnf_hash3(n + g);
                let r = g + o - f;
                let d = dot(r, r);
                if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
            }
        }
    }
    return sqrt(vec2<f32>(d1, d2));
}

fn worleyF1_3D(p: vec3<f32>) -> f32 { return _wnf_worley3D(p).x; }
fn worleyF2minusF1_3D(p: vec3<f32>) -> f32 { let f = _wnf_worley3D(p); return f.y - f.x; }

fn worleyF1_2D_manhattan(p: vec2<f32>) -> f32 {
    let n = floor(p);
    let f = fract(p);
    var d1 = 8.0;
    for (var j = -1; j <= 1; j++) {
        for (var i = -1; i <= 1; i++) {
            let g = vec2<f32>(f32(i), f32(j));
            let o = _wnf_hash2(n + g);
            let r = g + o - f;
            let d = abs(r.x) + abs(r.y);
            d1 = min(d1, d);
        }
    }
    return d1;
}

fn worleyF1_2D_chebyshev(p: vec2<f32>) -> f32 {
    let n = floor(p);
    let f = fract(p);
    var d1 = 8.0;
    for (var j = -1; j <= 1; j++) {
        for (var i = -1; i <= 1; i++) {
            let g = vec2<f32>(f32(i), f32(j));
            let o = _wnf_hash2(n + g);
            let r = g + o - f;
            let d = max(abs(r.x), abs(r.y));
            d1 = min(d1, d);
        }
    }
    return d1;
}
