# Adding Recipes

## Quick Start

1. Create a new JSON file in `noise_fields/recipes/`
2. Follow the recipe schema below
3. Add the entry to `recipes/index.json`
4. (Optional) Add shader chunks if using a new noise type

## Recipe Schema

```json
{
  "id": "your_recipe_id",
  "description": "One-line description of what this looks like.",
  "noise_graph": {
    "base": {
      "family": "noise_family_id",
      "preset": "canonical_parameter_set_id",
      "override": {}
    },
    "modifiers": [
      {
        "type": "domain_warp",
        "warp_noise": "simplex",
        "warp_strength": 0.5,
        "warp_frequency": 1.0
      }
    ]
  },
  "style_tags": ["tag1", "tag2"],
  "example_prompts": [
    "natural language description of how to invoke this recipe"
  ],
  "screenshot_metadata": {
    "camera": { "type": "ortho_uv" },
    "shading": "description_of_rendering",
    "notes": "Implementation hints"
  }
}
```

## Style Tag Guidelines

Good style tags are:

- **Visual** — what it looks like: "swirling", "jagged", "cellular", "soft"
- **Material** — what it resembles: "marble", "leather", "lava", "fog"
- **Emotional** — what it feels like: "eerie", "calm", "chaotic", "cosmic"
- **Technical** — noise specifics: "high frequency", "low lacunarity", "domain warped"

Aim for 4–8 tags per recipe. The first 2–3 should be the strongest visual descriptors.

## Modifier Types

| Type | Description | Required Fields |
|------|-------------|-----------------|
| `domain_warp` | Coordinate distortion | `warp_noise`, `warp_strength`, `warp_frequency` |
| `blend` | Mix with another noise | `blend_noise`, `blend_mode`, `blend_preset` |
| `invert` | Flip value range | (none) |
| `modulate_amplitude` | Multiply by another noise | `modulator`, `preset`, `strength` |

## Adding a New Noise Family

1. Create `noise_families/your_noise.json` following the common schema
2. Add GLSL chunk to `shaders/glsl/your_noise.glsl`
3. Add WGSL chunk to `shaders/wgsl/your_noise.wgsl`
4. Add entry to `noise_families/index.json`
5. Add at least one `canonical_parameter_set`

## Adding Parameter Presets

Add to the `canonical_parameter_sets` array in the relevant family JSON:

```json
{
  "id": "descriptive_name",
  "dimensions": 3,
  "space": "world",
  "base_frequency": 1.0,
  "octaves": 4,
  "lacunarity": 2.0,
  "gain": 0.5,
  "style_tags": ["what", "it", "looks", "like"]
}
```

The `id` should be `{family}_{visual_description}`, e.g., `perlin_soft_terrain`.
