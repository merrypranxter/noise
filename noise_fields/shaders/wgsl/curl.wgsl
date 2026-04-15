// shaders/wgsl/curl.wgsl
// Curl noise: divergence-free vector field via finite differences of scalar noise.

fn curlNoise2D(p : vec2<f32>, stepSize : f32) -> vec2<f32> {
    let dx : f32 = simplexNoise2D(p + vec2<f32>(stepSize, 0.0)) - simplexNoise2D(p - vec2<f32>(stepSize, 0.0));
    let dy : f32 = simplexNoise2D(p + vec2<f32>(0.0, stepSize)) - simplexNoise2D(p - vec2<f32>(0.0, stepSize));
    return vec2<f32>(dy, -dx) / (2.0 * stepSize);
}

fn curlNoise3D(p : vec3<f32>, stepSize : f32) -> vec3<f32> {
    let dx : vec3<f32> = vec3<f32>(stepSize, 0.0, 0.0);
    let dy : vec3<f32> = vec3<f32>(0.0, stepSize, 0.0);
    let dz : vec3<f32> = vec3<f32>(0.0, 0.0, stepSize);

    let dFz_dy : f32 = simplexNoise3D(p + dy) - simplexNoise3D(p - dy);
    let dFy_dz : f32 = simplexNoise3D(p + dz) - simplexNoise3D(p - dz);
    let dFx_dz : f32 = simplexNoise3D(p + dz + vec3<f32>(31.416, 0.0, 0.0)) - simplexNoise3D(p - dz + vec3<f32>(31.416, 0.0, 0.0));
    let dFz_dx : f32 = simplexNoise3D(p + dx) - simplexNoise3D(p - dx);
    let dFy_dx : f32 = simplexNoise3D(p + dx + vec3<f32>(0.0, 31.416, 0.0)) - simplexNoise3D(p - dx + vec3<f32>(0.0, 31.416, 0.0));
    let dFx_dy : f32 = simplexNoise3D(p + dy + vec3<f32>(0.0, 0.0, 31.416)) - simplexNoise3D(p - dy + vec3<f32>(0.0, 0.0, 31.416));

    return vec3<f32>(
        dFz_dy - dFy_dz,
        dFx_dz - dFz_dx,
        dFy_dx - dFx_dy
    ) / (2.0 * stepSize);
}
