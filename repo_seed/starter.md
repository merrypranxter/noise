# "noise_fields" Knowledge Pack Design for Reposcripter

## Overview

The `noise_fields` pack captures canonical procedural noise families and common combinators (FBM, ridged multifractals, domain warp, curl fields) as structured, machine‑readable knowledge plus shader snippets. It is designed so Reposcripter can talk about noise in semantic terms ("jagged ridged mountains" vs. "soft foggy clouds") and then lower that to concrete GLSL/WGSL implementations with appropriate parameters.[^1][^2]

## Intended Repository Layout

A minimal layout for a dedicated `noise_fields` repository could be:

```text
noise_fields/
  pack.json                    # Pack metadata and top‑level registry
  noise_families/
    perlin.json
    simplex.json
    worley.json
    fbm.json
    ridged_multifractal.json
    domain_warp.json
    curl.json
  combinators/
    fbm.json
    multifractal.json
    hybrid_multifractal.json
    domain_warp.json
  shaders/
    glsl/
      perlin.glsl
      simplex.glsl
      worley.glsl
      fbm.glsl
      ridged_multifractal.glsl
      domain_warp.glsl
      curl.glsl
    wgsl/
      perlin.wgsl
      simplex.wgsl
      worley.wgsl
      fbm.wgsl
      ridged_multifractal.wgsl
      domain_warp.wgsl
      curl.wgsl
  recipes/
    smoky_haze.json
    jagged_mountains.json
    cellular_leather.json
```

Each JSON descriptor is intended to be small and composable, while shader chunks are thin wrappers around well‑known GLSL noise implementations such as Patricio Gonzalez Vivo’s noise gists and related libraries.[^3][^4][^5]

## Top‑Level Pack Descriptor (`pack.json`)

The pack descriptor provides metadata and indexes all noise families, combinators, and style recipes so Reposcripter can enumerate and cross‑reference them.

```json
{
  "id": "noise_fields",
  "name": "Canonical Noise and Domain‑Warp Pack",
  "version": "0.1.0",
  "description": "Structured knowledge about common procedural noise families and combinators for generative shaders.",
  "tags": ["noise", "shaders", "glsl", "wgsl", "procedural"],
  "families_index": "noise_families/index.json",
  "combinators_index": "combinators/index.json",
  "recipes_index": "recipes/index.json"
}
```

Companion index files list available entities by ID and path so other packs or tools can reference them without hard‑coding filenames.

## Common JSON Schema for Noise Families

Each noise family JSON shares a common schema so the system can reason about them uniformly:

```json
{
  "id": "perlin",
  "display_name": "Perlin Noise",
  "mathematical_definition": "Gradient noise assigning pseudo‑random gradient vectors to lattice points and interpolating their dot products with offset vectors via a smoothstep kernel.",
  "dimension_support": [1, 2, 3, 4],
  "value_range": "approx. [-1, 1] before remapping",
  "visual_keywords": ["smooth", "organic", "cloudy", "rolling", "soft"],
  "good_for": ["clouds", "fog", "soft terrain", "organic textures"],
  "art_failure_modes": [
    "Visible grid artifacts when frequency is too low or interpolation is not smooth enough.",
    "Obvious repetition when tiling without a periodic variant.",
    "Looks bland if used without layering multiple octaves (FBM)."
  ],
  "canonical_parameter_sets": [],
  "shader_chunks": {
    "glsl": "shaders/glsl/perlin.glsl",
    "wgsl": "shaders/wgsl/perlin.wgsl"
  },
  "complexity_notes": {
    "relative_cost": "medium",
    "branching": "none",
    "texture_lookups": 0
  }
}
```

The key fields are:

- `mathematical_definition`: Short, human‑legible summary suitable for explanations and prompt grounding.[^2][^1]
- `dimension_support`: List of supported dimensionalities for that implementation.
- `visual_keywords`: Style tags Reposcripter can use in language models.
- `good_for`: Common use‑cases (terrain, clouds, leather, etc.).[^1][^2]
- `art_failure_modes`: How this noise tends to "fail" visually so prompts can avoid pathological settings.
- `canonical_parameter_sets`: Named parameter presets (detailed below).
- `shader_chunks`: Pointers to GLSL/WGSL implementations.
- `complexity_notes`: Hints for performance‑aware choices.

### Canonical Parameter Set Structure

Parameter sets let Reposcripter connect a phrase like "low‑lacunarity, high‑roughness ridged world‑space noise" to concrete parameter values.

```json
{
  "id": "perlin_soft_terrain",
  "dimensions": 3,
  "space": "world",
  "base_frequency": 0.75,
  "octaves": 5,
  "lacunarity": 2.0,
  "gain": 0.5,
  "warp": null,
  "output_remap": "0_1",
  "style_tags": ["rolling hills", "soft terrain", "low contrast"],
  "notes": ["Use for large‑scale ground undulation before adding detail layers."]
}
```

These parameter sets are stored in an array under `canonical_parameter_sets` for each family and can be re‑used or extended by recipes.

## Core Noise Families

### Perlin Noise (`noise_families/perlin.json`)

Perlin noise is a gradient‑based noise that assigns pseudo‑random gradients to lattice points and interpolates them, producing smooth, blobby patterns widely used in textures and terrain.[^2][^1]

Key content for `perlin.json` beyond the generic schema:

```json
{
  "canonical_parameter_sets": [
    {
      "id": "perlin_soft_terrain",
      "dimensions": 3,
      "space": "world",
      "base_frequency": 0.5,
      "octaves": 4,
      "lacunarity": 2.0,
      "gain": 0.5,
      "style_tags": ["rolling hills", "soft", "low jaggedness"]
    },
    {
      "id": "perlin_fog",
      "dimensions": 3,
      "space": "world",
      "base_frequency": 1.8,
      "octaves": 5,
      "lacunarity": 2.0,
      "gain": 0.55,
      "style_tags": ["fog", "smoke", "soft turbulence"]
    }
  ]
}
```

### Simplex Noise (`noise_families/simplex.json`)

Simplex noise is an improved gradient noise that samples over simplices (triangles/tetrahedra) instead of a grid, reducing artifacts and improving performance in higher dimensions.[^1][^2]

Augmented fields:

```json
{
  "id": "simplex",
  "display_name": "Simplex Noise",
  "mathematical_definition": "Gradient noise defined over simplices (triangles/tetrahedra) with fewer directional artifacts and better scalability than classic Perlin noise.",
  "dimension_support": [2, 3, 4],
  "value_range": "approx. [-1, 1]",
  "visual_keywords": ["smooth", "organic", "isotropic", "fine detail"],
  "good_for": ["high‑frequency detail", "clouds", "volumetric effects"],
  "art_failure_modes": [
    "Can look too uniform when used alone at low octaves.",
    "Aliasing if sampled at very high frequency without filtering."
  ],
  "canonical_parameter_sets": [
    {
      "id": "simplex_detail_layer",
      "dimensions": 3,
      "space": "world",
      "base_frequency": 3.0,
      "octaves": 3,
      "lacunarity": 2.2,
      "gain": 0.45,
      "style_tags": ["fine detail", "micro variation"]
    }
  ]
}
```

### Worley / Cellular Noise (`noise_families/worley.json`)

Worley (cellular) noise computes distances from sample points to nearby feature points distributed in space, producing cell‑like or stone‑like patterns.[^6][^2]

Key schema specializations:

```json
{
  "id": "worley",
  "display_name": "Worley (Cellular) Noise",
  "mathematical_definition": "Cellular noise derived from distances to Poisson‑distributed feature points, often using F1 or F2-F1 metrics.",
  "dimension_support": [2, 3],
  "value_range": "[0, 1] after normalization of distance metric",
  "visual_keywords": ["cellular", "stone", "cracked", "leather"],
  "good_for": ["cells", "rocks", "veins", "stylized leather"],
  "art_failure_modes": [
    "Obvious grid repetition when the point pattern is not randomized enough.",
    "Aliasing on sharp cell borders without anti‑aliasing.",
    "Can look synthetic if used at a single scale." 
  ],
  "parameters": {
    "metric": ["euclidean", "manhattan", "chebyshev"],
    "channels": ["F1", "F2", "F2_minus_F1"]
  },
  "canonical_parameter_sets": [
    {
      "id": "worley_leather",
      "dimensions": 2,
      "space": "uv",
      "base_frequency": 6.0,
      "metric": "euclidean",
      "channel": "F2_minus_F1",
      "style_tags": ["cellular", "leather", "organic surface"]
    }
  ]
}
```

### Fractal Brownian Motion (FBM) (`noise_families/fbm.json`)

FBM is a combinator that sums multiple octaves of a base noise (typically Perlin or Simplex) with increasing frequency (`lacunarity`) and decreasing amplitude (`gain`) to create fractal‑like detail.[^7][^2]

```json
{
  "id": "fbm",
  "display_name": "Fractal Brownian Motion",
  "base_noise_family": ["perlin", "simplex"],
  "mathematical_definition": "Sum of N octaves of a base noise with frequency multiplied by lacunarity and amplitude scaled by gain each octave.",
  "visual_keywords": ["fractal", "layered", "natural"],
  "good_for": ["terrain", "clouds", "wood", "marble"],
  "art_failure_modes": [
    "Too many octaves produce noisy, grainy results.",
    "High lacunarity with low gain can create harsh, brittle patterns."
  ],
  "canonical_parameter_sets": [
    {
      "id": "fbm_soft_clouds",
      "base_noise": "perlin",
      "dimensions": 3,
      "octaves": 5,
      "base_frequency": 1.2,
      "lacunarity": 2.0,
      "gain": 0.5,
      "style_tags": ["soft clouds", "volumetric haze"]
    }
  ]
}
```

### Ridged Multifractal (`noise_families/ridged_multifractal.json`)

Ridged multifractal noise inverts and sharpens FBM‑like signals to yield sharp ridges suitable for mountains and jagged structures.[^2][^1]

```json
{
  "id": "ridged_multifractal",
  "display_name": "Ridged Multifractal",
  "base_noise_family": ["perlin", "simplex"],
  "mathematical_definition": "Multifractal combination that uses absolute value and inversion of base noise to emphasize ridges before summing octaves.",
  "visual_keywords": ["jagged", "mountainous", "craggy", "hard"],
  "good_for": ["mountain ranges", "rocky cliffs", "alien terrain"],
  "art_failure_modes": [
    "High gain and lacunarity produce visually noisy, harsh surfaces.",
    "Overused as a single layer, everything looks like spikes."
  ],
  "canonical_parameter_sets": [
    {
      "id": "ridged_mountains_low_lacunarity",
      "base_noise": "simplex",
      "dimensions": 3,
      "space": "world",
      "octaves": 6,
      "base_frequency": 1.5,
      "lacunarity": 1.8,
      "gain": 0.75,
      "style_tags": ["mountains", "jagged", "large scale"],
      "notes": ["Use with world‑space coordinates for stable terrain."]
    }
  ]
}
```

### Domain Warp (`noise_families/domain_warp.json`)

Domain warping feeds one or more noise fields into the input coordinates of another noise, creating swirled, turbulent patterns widely used for smoke, fire, and psychedelic textures.[^8][^7]

```json
{
  "id": "domain_warp",
  "display_name": "Domain Warp",
  "mathematical_definition": "Composes a base noise with warped coordinates x' = x + warp_noise(x) * warp_strength, often with different frequencies per axis.",
  "visual_keywords": ["swirled", "turbulent", "warped", "psychedelic"],
  "good_for": ["smoke", "fire", "marble", "psychedelic patterns"],
  "art_failure_modes": [
    "Too much warp strength destroys recognizable structure.",
    "Layered warps can fold space so aggressively that animation flickers." 
  ],
  "parameters": {
    "base_noise": ["perlin", "simplex", "fbm"],
    "warp_noise": ["simplex", "fbm"],
    "warp_strength": {
      "min": 0.0,
      "max": 3.0,
      "typical": [0.25, 1.0]
    }
  }
}
```

### Curl Noise (`noise_families/curl.json`)

Curl noise constructs a divergence‑free vector field by taking the curl of a potential defined by an underlying scalar noise, widely used for fluid‑like motion and turbulence.[^9][^2]

```json
{
  "id": "curl",
  "display_name": "Curl Noise",
  "mathematical_definition": "A divergence‑free vector field computed as the curl of an underlying scalar noise field, approximated via finite differences.",
  "dimension_support": [2, 3],
  "value_range": "vector field, magnitude depends on step size and frequency",
  "visual_keywords": ["turbulent", "vortices", "flow", "swirling"],
  "good_for": ["velocity fields", "smoke advection", "abstract flow patterns"],
  "art_failure_modes": [
    "Too large step size produces numerical artifacts and non‑smooth flow.",
    "Very high frequency causes jittery, noisy motion."
  ],
  "canonical_parameter_sets": [
    {
      "id": "curl_soft_vortices",
      "dimensions": 3,
      "base_noise": "simplex",
      "step_size": 0.1,
      "frequency": 1.5,
      "style_tags": ["large vortices", "soft flow"]
    }
  ]
}
```

## Shader Chunk Conventions

Shader chunks are not copied verbatim from existing libraries but should follow common patterns and be thin wrappers around canonical implementations like `webgl-noise`, `gl-Noise`, or Patricio Gonzalez Vivo’s Lygia noise utilities.[^4][^5][^3]

### Example GLSL Chunk Header

All GLSL chunks share a minimal interface for Reposcripter to assemble:

```glsl
// shaders/glsl/perlin.glsl
// Perlin gradient noise, 2D/3D variants.

#ifndef NOISE_FIELDS_PERLIN_GLSL
#define NOISE_FIELDS_PERLIN_GLSL

float perlinNoise(vec2 p);
float perlinNoise(vec3 p);

#endif
```

Implementation bodies can be adapted from well‑known references (e.g., `stegu/webgl-noise`, `gl-Noise`, or Lygia’s `generative` module) under appropriate licenses, but the knowledge pack only needs the stable API and a short comment documenting algorithm origin.[^5][^3][^4]

### Example Combinator Chunk

```glsl
// shaders/glsl/fbm.glsl

#ifndef NOISE_FIELDS_FBM_GLSL
#define NOISE_FIELDS_FBM_GLSL

float fbmPerlin(vec3 p, int octaves, float baseFreq, float lacunarity, float gain) {
    float amp = 1.0;
    float freq = baseFreq;
    float sum = 0.0;
    for (int i = 0; i < octaves; ++i) {
        sum += amp * perlinNoise(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

#endif
```

WGSL chunks mirror these interfaces but use WGSL types and module syntax:

```wgsl
// shaders/wgsl/perlin.wgsl

fn perlinNoise2D(p : vec2<f32>) -> f32;
fn perlinNoise3D(p : vec3<f32>) -> f32;
```

## Style‑Linked Recipes

Recipes tie specific parameter sets and combinators to descriptive style tags and example prompts.

### Example: Jagged Mountains

```json
{
  "id": "jagged_mountains",
  "description": "Ridged multifractal world‑space noise for sharp, craggy mountain ranges.",
  "noise_graph": {
    "base": {
      "family": "ridged_multifractal",
      "preset": "ridged_mountains_low_lacunarity"
    },
    "modifiers": [
      {
        "type": "domain_warp",
        "warp_noise": "fbm",
        "warp_strength": 0.4,
        "warp_frequency": 0.8
      }
    ]
  },
  "style_tags": [
    "jagged mountains",
    "high roughness",
    "low lacunarity",
    "craggy",
    "alien terrain"
  ],
  "example_prompts": [
    "use ridged multifractal world‑space noise with low lacunarity and high roughness for jagged mountains",
    "compose a mountainous heightfield from ridged multifractal noise with subtle domain warp"
  ],
  "screenshot_metadata": {
    "camera": {
      "type": "ortho_topdown",
      "scale": 200.0
    },
    "shading": "height_to_grayscale",
    "notes": "Render heightfield at 1024x1024 as 16‑bit grayscale texture."
  }
}
```

### Example: Smoky Volumetric Haze

```json
{
  "id": "smoky_volumetric_haze",
  "description": "Soft, billowy volumetric haze using FBM of Perlin or Simplex with light domain warping.",
  "noise_graph": {
    "base": {
      "family": "fbm",
      "preset": "fbm_soft_clouds"
    },
    "modifiers": [
      {
        "type": "domain_warp",
        "warp_noise": "simplex",
        "warp_strength": 0.3,
        "warp_frequency": 2.0
      }
    ]
  },
  "style_tags": ["smoky", "volumetric", "soft", "haze"],
  "example_prompts": [
    "use 3D FBM noise with low contrast and subtle domain warping for smoky volumetric haze",
    "layer soft FBM Perlin clouds in world space for fog"
  ],
  "screenshot_metadata": {
    "camera": { "type": "perspective", "notes": "Render a mid‑density volume slice." },
    "shading": "single‑scattering approximation"
  }
}
```

### Example: Cellular Leather

```json
{
  "id": "cellular_leather",
  "description": "Cellular texture resembling worn leather using Worley F2-F1 channels.",
  "noise_graph": {
    "base": {
      "family": "worley",
      "preset": "worley_leather"
    },
    "modifiers": []
  },
  "style_tags": ["cellular", "leather", "organic surface"],
  "example_prompts": [
    "use 2D Worley noise (F2 minus F1) in UV space for a cellular leather texture",
    "drive roughness with cellular Worley noise to mimic worn leather"
  ],
  "screenshot_metadata": {
    "camera": { "type": "ortho_uv" },
    "shading": "albedo + roughness preview"
  }
}
```

## How Reposcripter Can Use This Pack

With this structure, Reposcripter can:

- Parse `noise_families/*.json` to understand which noise types exist, where their shader chunks live, and how they are typically used.
- Map natural‑language descriptions like "ridged multifractal world‑space noise with low lacunarity" to specific parameter presets.
- Compose complex noise graphs by following `noise_graph` recipes combining families and combinators.
- Choose GLSL vs. WGSL implementations depending on the target runtime while keeping semantic metadata the same.

The pack thus turns fragmented shader gists and tutorials into a coherent, queryable knowledge base about procedural noise, aligned with established GLSL noise practices and documentation.[^3][^4][^8][^1][^2]

---

