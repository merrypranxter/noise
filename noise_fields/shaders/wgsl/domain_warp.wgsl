// shaders/wgsl/domain_warp.wgsl
// Domain warp utility: distort coordinates using a warp noise before sampling base noise.

fn domainWarp2D(p : vec2<f32>, warpStrength : f32, warpFreq : f32) -> vec2<f32> {
    return p + vec2<f32>(
        simplexNoise2D(p * warpFreq),
        simplexNoise2D(p * warpFreq + vec2<f32>(5.2, 1.3))
    ) * warpStrength;
}

fn domainWarp3D(p : vec3<f32>, warpStrength : f32, warpFreq : f32) -> vec3<f32> {
    return p + vec3<f32>(
        simplexNoise3D(p * warpFreq),
        simplexNoise3D(p * warpFreq + vec3<f32>(5.2, 1.3, 9.7)),
        simplexNoise3D(p * warpFreq + vec3<f32>(2.8, 7.1, 4.6))
    ) * warpStrength;
}
