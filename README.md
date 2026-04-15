# noise_fields

**Canonical Noise and Domain-Warp Knowledge Pack for Reposcripter**

A structured, machine-readable knowledge pack that captures canonical procedural noise families and common combinators (FBM, ridged multifractals, domain warp, curl fields) as JSON descriptors plus GLSL/WGSL shader snippets. Designed so Reposcripter can reason about noise in semantic terms ("jagged ridged mountains" vs. "soft foggy clouds") and lower that to concrete shader implementations with appropriate parameters.

## Repository Layout

```text
noise_fields/
  pack.json                        # Pack metadata and top-level registry
  noise_families/
    index.json                     # Index of all noise families
    perlin.json                    # Perlin gradient noise
    simplex.json                   # Simplex gradient noise
    worley.json                    # Worley (cellular) noise
    fbm.json                       # Fractal Brownian Motion
    ridged_multifractal.json       # Ridged multifractal noise
    domain_warp.json               # Domain warping
    curl.json                      # Curl noise (divergence-free fields)
  combinators/
    index.json                     # Index of all combinators
    fbm.json                       # FBM combinator
    multifractal.json              # Multifractal combinator
    hybrid_multifractal.json       # Hybrid multifractal combinator
    domain_warp.json               # Domain warp combinator
  shaders/
    glsl/                          # GLSL shader chunks
      perlin.glsl
      simplex.glsl
      worley.glsl
      fbm.glsl
      ridged_multifractal.glsl
      domain_warp.glsl
      curl.glsl
    wgsl/                          # WGSL shader chunks
      perlin.wgsl
      simplex.wgsl
      worley.wgsl
      fbm.wgsl
      ridged_multifractal.wgsl
      domain_warp.wgsl
      curl.wgsl
  recipes/
    index.json                     # Index of all style recipes
    smoky_haze.json                # Soft volumetric haze recipe
    jagged_mountains.json          # Craggy mountain terrain recipe
    cellular_leather.json          # Worn leather texture recipe
```

## Noise Families

| Family | Description | Visual Keywords |
|--------|-------------|-----------------|
| **Perlin** | Classic gradient noise on a lattice | smooth, organic, cloudy, rolling |
| **Simplex** | Improved gradient noise over simplices | smooth, isotropic, fine detail |
| **Worley** | Cellular noise from feature-point distances | cellular, stone, cracked, leather |
| **FBM** | Fractal layering of octaves | fractal, layered, natural |
| **Ridged Multifractal** | Inverted/sharpened FBM for ridges | jagged, mountainous, craggy |
| **Domain Warp** | Coordinate distortion via noise | swirled, turbulent, psychedelic |
| **Curl** | Divergence-free vector field | turbulent, vortices, flow |

## Combinators

Combinators define how base noise functions are composed:

- **FBM** — Additive octave summation with lacunarity and gain
- **Multifractal** — Multiplicative octave combination for heterogeneous detail
- **Hybrid Multifractal** — Blend of additive and multiplicative approaches
- **Domain Warp** — Coordinate distortion using a secondary noise field

## Style Recipes

Recipes connect semantic descriptions to concrete noise configurations:

- **Jagged Mountains** — Ridged multifractal with subtle domain warp for craggy terrain
- **Smoky Volumetric Haze** — FBM Perlin with light domain warping for soft fog
- **Cellular Leather** — Worley F2-F1 in UV space for worn leather textures

## How Reposcripter Uses This Pack

1. Parse `noise_families/*.json` to enumerate available noise types, their shader chunks, and visual semantics
2. Map natural-language descriptions to specific parameter presets via `canonical_parameter_sets`
3. Compose complex noise graphs by following `noise_graph` recipes combining families and combinators
4. Choose GLSL vs. WGSL implementations depending on the target runtime

## Shader Conventions

- GLSL chunks use include guards (`#ifndef NOISE_FIELDS_*_GLSL`)
- WGSL chunks mirror GLSL interfaces with appropriate WGSL types
- Chunks define stable API signatures; function bodies can be adapted from established libraries (webgl-noise, gl-Noise, Lygia)
