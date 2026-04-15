# Examples

Working shader examples demonstrating noise_fields recipes.

## Files

### `psychedelic_fullscreen.glsl`
Standalone fragment shader with iterative domain warp (IQ-style).
Demonstrates the `psychedelic_warp` recipe.

**Where to run it:**
- [glslEditor](http://editor.thebookofshaders.com/) — paste directly
- Any WebGL sandbox with `u_time` and `u_resolution` uniforms

### `shadertoy_lava.glsl`
ShaderToy-format shader implementing the `lava_flow` recipe.
Animated Worley F2-F1 with domain warp and black body color mapping.

**Where to run it:**
- [ShaderToy](https://www.shadertoy.com/new) — paste as Image shader

## Adding Examples

When adding a new example:
1. Name it descriptively: `{recipe_name}_{target_platform}.glsl`
2. Include inline noise implementations (examples should be self-contained)
3. Add comments explaining which recipe/family is being demonstrated
4. Note the target platform and required uniforms at the top
