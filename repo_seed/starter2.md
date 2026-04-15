Here’s a concrete design for the `noise_fields` pack as a repo‑shaped knowledge pack you can hand to Reposcripter; it includes JSON schemas, example instances for core noise families, and how GLSL/WGSL chunks should be organized and referenced.[1][2][3][4]

## What the repo looks like

A minimal standalone repository layout for `noise_fields`:

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

Shader chunks are thin wrappers around standard GLSL noise implementations (e.g., Patricio Gonzalez Vivo’s gists, Lygia’s `generative` module, or `webgl-noise`), but the pack’s main value is the structured JSON that encodes semantics.[2][5][1]

## `pack.json`: top‑level metadata and indexes

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

Each index file is a small list of entries like `{ "id": "perlin", "path": "noise_families/perlin.json" }`, so Reposcripter can enumerate types without hard‑coded paths.

## Common JSON schema for a noise family

Every family JSON has the same core fields so you can reason about them uniformly and tag them semantically:

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

Key semantic fields (for the LLM side) are `mathematical_definition`, `visual_keywords`, `good_for`, `art_failure_modes`, and `canonical_parameter_sets`, all grounded in how Perlin/simplex/Worley/curl are described in procedural‑graphics literature.[3][6]

### Canonical parameter sets (what “low lacunarity, high roughness” means)

Parameter sets give a machine‑readable mapping from phrases like “low‑lacunarity, high‑roughness ridged world‑space noise” to concrete numbers:

```json
{
  "id": "perlin_soft_terrain",
  "dimensions": 3,
  "space": "world",
  "base_frequency": 0.5,
  "octaves": 4,
  "lacunarity": 2.0,
  "gain": 0.5,
  "warp": null,
  "output_remap": "0_1",
  "style_tags": ["rolling hills", "soft terrain", "low jaggedness"],
  "notes": ["Use for large‑scale ground undulation before adding detail layers."]
}
```

Each family’s JSON keeps an array of such blocks under `canonical_parameter_sets`.

## Core family descriptors

Below are representative JSONs for the main families you mentioned. They all follow the shared schema; only the interesting bits are shown.

### Perlin (`noise_families/perlin.json`)

Perlin is standard gradient noise, widely used for terrain and organic textures.[6][3]

```json
{
  "id": "perlin",
  "display_name": "Perlin Noise",
  "mathematical_definition": "Gradient noise assigning pseudo‑random gradients to lattice points and interpolating their dot products with offset vectors via a smoothstep kernel.",
  "dimension_support": [1, 2, 3, 4],
  "value_range": "approx. [-1, 1] before remapping",
  "visual_keywords": ["smooth", "organic", "cloudy", "rolling", "soft"],
  "good_for": ["clouds", "fog", "soft terrain", "organic textures"],
  "art_failure_modes": [
    "Visible grid artifacts when frequency is too low or interpolation is not smooth enough.",
    "Obvious repetition when tiling without a periodic variant.",
    "Looks bland if used without layering multiple octaves (FBM)."
  ],
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
  ],
  "shader_chunks": {
    "glsl": "shaders/glsl/perlin.glsl",
    "wgsl": "shaders/wgsl/perlin.wgsl"
  }
}
```

### Simplex (`noise_families/simplex.json`)

Simplex noise is the improved gradient noise over simplices, with fewer artifacts and better high‑dim behavior.[3][6]

```json
{
  "id": "simplex",
  "display_name": "Simplex Noise",
  "mathematical_definition": "Gradient noise defined over simplices (triangles/tetrahedra) with fewer directional artifacts and better scalability than classic Perlin noise.",
  "dimension_support": [2, 3, 4],
  "value_range": "approx. [-1, 1]",
  "visual_keywords": ["smooth", "organic", "isotropic", "fine detail"],
  "good_for": ["high-frequency detail", "clouds", "volumetric effects"],
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
  ],
  "shader_chunks": {
    "glsl": "shaders/glsl/simplex.glsl",
    "wgsl": "shaders/wgsl/simplex.wgsl"
  }
}
```

### Worley / cellular (`noise_families/worley.json`)

Cellular noise using distances to scattered feature points; great for cells, stones, “leather”.[7][3]

```json
{
  "id": "worley",
  "display_name": "Worley (Cellular) Noise",
  "mathematical_definition": "Cellular noise derived from distances to Poisson-distributed feature points, often using F1 or F2-F1 metrics.",
  "dimension_support": [2, 3],
  "value_range": "[0, 1] after normalization of distance metric",
  "visual_keywords": ["cellular", "stone", "cracked", "leather"],
  "good_for": ["cells", "rocks", "veins", "stylized leather"],
  "art_failure_modes": [
    "Obvious grid repetition when the point pattern is not randomized enough.",
    "Aliasing on sharp cell borders without anti-aliasing.",
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
  ],
  "shader_chunks": {
    "glsl": "shaders/glsl/worley.glsl",
    "wgsl": "shaders/wgsl/worley.wgsl"
  }
}
```

### FBM combinator (`noise_families/fbm.json`)

Fractal Brownian Motion is a layered sum of octaves of a base noise.[8][3]

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
  ],
  "shader_chunks": {
    "glsl": "shaders/glsl/fbm.glsl",
    "wgsl": "shaders/wgsl/fbm.wgsl"
  }
}
```

### Ridged multifractal (`noise_families/ridged_multifractal.json`)

Ridged multifractal inverts and sharpens FBM‑like patterns for mountains and craggy structures.[6][3]

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
      "notes": ["Use with world-space coordinates for stable terrain."]
    }
  ],
  "shader_chunks": {
    "glsl": "shaders/glsl/ridged_multifractal.glsl",
    "wgsl": "shaders/wgsl/ridged_multifractal.wgsl"
  }
}
```

### Domain warp (`noise_families/domain_warp.json`)

Domain warping feeds one noise into another’s coordinates for swirled/turbulent patterns.[4][8]

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
  },
  "shader_chunks": {
    "glsl": "shaders/glsl/domain_warp.glsl",
    "wgsl": "shaders/wgsl/domain_warp.wgsl"
  }
}
```

### Curl noise (`noise_families/curl.json`)

Curl noise is a divergence‑free vector field constructed from an underlying scalar noise; you see it everywhere in flow fields and pyro.[9][3]

```json
{
  "id": "curl",
  "display_name": "Curl Noise",
  "mathematical_definition": "A divergence-free vector field computed as the curl of an underlying scalar noise field, approximated via finite differences.",
  "dimension_support": [2, 3],
  "value_range": "vector field, magnitude depends on step size and frequency",
  "visual_keywords": ["turbulent", "vortices", "flow", "swirling"],
  "good_for": ["velocity fields", "smoke advection", "abstract flow patterns"],
  "art_failure_modes": [
    "Too large step size produces numerical artifacts and non-smooth flow.",
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
  ],
  "shader_chunks": {
    "glsl": "shaders/glsl/curl.glsl",
    "wgsl": "shaders/wgsl/curl.wgsl"
  }
}
```

## Shader chunk conventions (GLSL/WGSL)

The chunks are small, stable APIs; their bodies can be adapted from existing noise libraries like `webgl-noise`, `gl-Noise`, or Lygia’s `generative` collection.[5][1][2]

### GLSL: example headers and FBM combinator

```glsl
// shaders/glsl/perlin.glsl
// Perlin gradient noise, 2D/3D variants.

#ifndef NOISE_FIELDS_PERLIN_GLSL
#define NOISE_FIELDS_PERLIN_GLSL

float perlinNoise(vec2 p);
float perlinNoise(vec3 p);

#endif
```

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

WGSL mirrors these with appropriate types:

```wgsl
// shaders/wgsl/perlin.wgsl

fn perlinNoise2D(p : vec2<f32>) -> f32;
fn perlinNoise3D(p : vec3<f32>) -> f32;
```

The pack only needs to guarantee interface signatures and provenance comments; actual function bodies can be pulled from the libraries you already like.

## Style‑linked recipes (noise graph + prompts)

Recipes link specific parameter presets and combinators to human‑language labels, example prompts, and optional screenshot metadata. These are what let you say “smoky volumetric haze” and have the system assemble the right graph.

### `recipes/jagged_mountains.json`

```json
{
  "id": "jagged_mountains",
  "description": "Ridged multifractal world-space noise for sharp, craggy mountain ranges.",
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
        "warp_frequency": 0.8"
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
    "use ridged multifractal world-space noise with low lacunarity and high roughness for jagged mountains",
    "compose a mountainous heightfield from ridged multifractal noise with subtle domain warp"
  ],
  "screenshot_metadata": {
    "camera": {
      "type": "ortho_topdown",
      "scale": 200.0
    },
    "shading": "height_to_grayscale",
    "notes": "Render heightfield at 1024x1024 as 16-bit grayscale texture."
  }
}
```

### `recipes/smoky_haze.json`

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
    "camera": { "type": "perspective", "notes": "Render a mid-density volume slice." },
    "shading": "single-scattering approximation"
  }
}
```

### `recipes/cellular_leather.json`

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

## How Reposcripter can use this pack

With this structure in a repo owned by `merrypranxter`, Reposcripter (or any higher‑level agent) can:

- Read `noise_families/*.json` to know what families exist, what dimensions they support, where the GLSL/WGSL chunks live, and what visual styles they map to.[1][2][3]
- Interpret natural‑language instructions like “use ridged multifractal world‑space noise with low lacunarity and high roughness” by resolving to `ridged_multifractal` + the `ridged_mountains_low_lacunarity` preset and composing modifiers from recipes.
- Choose an implementation path (GLSL vs WGSL, Perlin vs Simplex vs Worley) based on `good_for`, `art_failure_modes`, and `complexity_notes`.
- Generate example shaders, screenshots, or docs for each recipe using `screenshot_metadata` hints and the shader chunk APIs, leveraging the established GLSL noise references you already know.[2][4][1]

If you’d like, the next step can be: pick a target (GLSL or WGSL first), and I can flesh out one or two of the actual shader chunk implementations in the style you prefer so you can drop them into a real GitHub repo.

Sources
[1] Generating Noise for applications https://learn.microsoft.com/en-us/archive/blogs/hemipteran/generating-noise-for-applications
[2] Notes on Noise https://www.katexagoraris.com/misc/notes-on-noise
[3] GLSL Noise Algorithms - GitHub Gist https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
[4] GLSL noise library: Simplex and Perlin noise https://stegu.github.io/webgl-noise/webdemo/
[5] gl-Noise | Home https://farazzshaikh.github.io/glNoise/
[6] GLSL noise library: cellular noise variants - Red Blob Games https://www.redblobgames.com/x/2107-webgl-noise/webgl-noise/webdemo/cellular.html
[7] Noise - The Book of Shaders https://thebookofshaders.com/11/
[8] Mastering GLSL in TouchDesigner, Lesson 6: Basic Procedural Noise https://www.youtube.com/watch?v=_u5IOMOmolY
[9] VOP —— Noise https://blog.csdn.net/NapoleonCoder/article/details/133017249
[10] Next-Knowledge-Pack-Repos-for-Reposcripter.pdf https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/106356840/53db5ada-7c10-4fff-b11a-7d223377f4ed/Next-Knowledge-Pack-Repos-for-Reposcripter.pdf?AWSAccessKeyId=ASIA2F3EMEYE2RLT2UP6&Signature=mmbm1kZKBMZsL%2BGdtPIye5S7fh0%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEN%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQDO5vYv5aU6Y1yfV%2BEbeqesYQofdHQUFVmSCQIS8HPYpgIgX2mYfPXdN%2BbztVaHlpv3GXDKwYRzBo22tFvjNVXgDLwq%2FAQIp%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARABGgw2OTk3NTMzMDk3MDUiDG10881ZexOPoMzQjSrQBK5gAxZSECxjW2n688y51Y9%2FZXYS7gpURKlSrGQnC9biHfOqPk%2BLu02iOYrnAIpCntJ5xWkdytADSWV4GB2s8aUhboS%2BMPqL7pNVBcf6nAP83fC56xdrRZpJIh2MQBCuJ2vC6i01fHufq0S0kFUoKhEGlpdCNfvhTxXu4aLblGC5fGRgZqTeePSU2WRwvWddrXAct6OJudMUZxEWiUPC2tCqnv6GvGpartApUCrWi5NSYSA1uPwefO%2F2N%2B5TPAmSmvZE25IFPkXWjUDv%2FhliJdr3zk2zn1kztpsVgpi5QYZM%2B1pfkpNfmjBMWQbKRpHQKcMFFi6fFJ19O7jOoxLWX53UCpQnT1a0pwvjdTxs0hBfahxb1L6RKEh%2BavSm3nHZyKOuZdkroP%2B2Edrps%2B4y4h6%2B1utkhrc1mwgkJCJVCSWoSn6tcAISMqKnqGBVk2cvzB2yjungsQkGyMj72tSc3Apbz71XqrOOvVfEtV7Mcf65hq7sk%2FSdZGyPnjheqlwTLzpnIZbPW4yWklrG7ngl4wYWYYz8%2BBQFNSL4x8otLglMBM7cmIC72FUX9fAmZ227Cb4z3uUeC4l1z8wOWDRlM%2BG9%2B4%2Bm4ALLjZamQBZFMkYUNWpBAWu3Co00XlYmv0y59%2BYA4X5E3HjAvB%2FuWh5DmwkhR43ONHrM2QxnrxMn3azlMfHEenhRn%2FPtYCTa7nuKxg1c54o%2FNVNY0gxwcYNYIkWHjwBrAhSlxGlFcR0XlPole4a1RvayKTV0zlX0TMTaxdYJTD0GXMu4sfvZ57Hdu3ww2rz%2BzgY6mAFHGiZ2RJKLomrsgYrTbcxsNl7UC6p8Mf1qKLH1q8SGYKtDQ9dPC2q%2B4cyoH1iLEZCzfOSLbyd9d6MGAun5lsFzb%2FdHfX1UjfByH2Kdx4TTVhptoq1uhUAanhSTaT%2BEXLSSVWH8%2B2tjccF%2BKFhN64PLiL2zbcvzErJ%2F15zxW4GjWTUFa8z4VRn9ziX6CW91fid1DD29YKFRdQ%3D%3D&Expires=1776265658
[11] pasted-text.txt https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_18f628c6-c8b6-4c00-87b5-c635a5aa5af9/107abb68-128f-4fa7-8333-337696471db8/pasted-text.txt
[12] pasted-text.txt https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_18f628c6-c8b6-4c00-87b5-c635a5aa5af9/1559ee1d-dd46-48bd-9a3c-69a9cc54fd79/pasted-text.txt
[13] pasted-text.txt https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_18f628c6-c8b6-4c00-87b5-c635a5aa5af9/26dbdebd-f4fb-4a85-905f-d7ba407f83d0/pasted-text.txt
[14] Patricio Gonzalez Vivo patriciogonzalezvivo - GitHub Gist https://gist.github.com/patriciogonzalezvivo?direction=desc&sort=updated
[15] Random / noise functions for GLSL - shader - Stack Overflow https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
[16] a plea for help understanding simplex noise implementation in glsl https://www.reddit.com/r/proceduralgeneration/comments/mi25yg/surrendering_now_a_plea_for_help_understanding/
[17] GitHub - FarazzShaikh/glNoise: A collection of GLSL noise functions ... https://github.com/farazzshaikh/glNoise
[18] shader-noise - Skill | Smithery https://smithery.ai/skills/Bbeierle12/shader-noise
[19] Added 3D Noise and Blend Modes to my GLSL Noise library (gl ... https://www.reddit.com/r/proceduralgeneration/comments/npsk8r/added_3d_noise_and_blend_modes_to_my_glsl_noise/
