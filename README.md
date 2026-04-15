# noise_fields

**Canonical Noise & Domain-Warp Knowledge Pack for [RepoScripter](https://github.com/merrypranxter/reposcripter2)**

A structured, machine-readable knowledge pack that captures procedural noise families and combinators as JSON descriptors + working GLSL/WGSL shader implementations. Designed so RepoScripter (or any LLM-driven shader tool) can reason about noise in semantic terms — "jagged ridged mountains", "psychedelic deep warp", "glowing lava cracks" — and lower that to concrete shader code with tuned parameters.

## What This Is

Not a shader library. A **knowledge base** that encodes:

- **What** each noise type looks like (visual keywords, style tags)
- **When** to use it (good_for) and when it breaks (art_failure_modes)
- **How** to configure it (canonical parameter sets mapping phrases → numbers)
- **Where** the code lives (GLSL + WGSL shader chunks)
- **Recipes** that compose noise types into complete visual styles

## Quick Start

```bash
git clone https://github.com/merrypranxter/noise.git
```

Browse the JSON descriptors:
```bash
cat noise_fields/noise_families/perlin.json    # What is Perlin noise?
cat noise_fields/recipes/psychedelic_warp.json  # How to make trippy patterns
```

Try a shader example:
```bash
# Copy examples/shadertoy_lava.glsl → paste into shadertoy.com
# Copy examples/psychedelic_fullscreen.glsl → paste into glslEditor
```

## Noise Families

| Family | Visual Keywords | Good For |
|--------|----------------|----------|
| **Perlin** | smooth, organic, cloudy, rolling | clouds, fog, soft terrain |
| **Simplex** | smooth, isotropic, fine detail | high-freq detail, volumetrics |
| **Worley** | cellular, stone, cracked, leather | cells, rocks, veins, lava |
| **FBM** | fractal, layered, natural | terrain, clouds, wood, marble |
| **Ridged Multifractal** | jagged, mountainous, craggy | mountains, rocky cliffs |
| **Domain Warp** | swirled, turbulent, psychedelic | smoke, fire, marble, acid |
| **Curl** | turbulent, vortices, flow | velocity fields, tendrils, advection |
| **Value** | soft, blobby, painterly, cheap | heightmaps, watercolour, performance |
| **Gabor** | oriented, fibrous, brushstroke, anisotropic | fabric, hair, wood grain, brushstrokes |

## Combinators

| Combinator | What It Does | Accepts |
|------------|-------------|---------|
| **FBM** | Additive octave stacking | perlin, simplex, worley |
| **Multifractal** | Multiplicative octave combination | perlin, simplex |
| **Hybrid Multifractal** | Additive + multiplicative blend | perlin, simplex |
| **Domain Warp** | Coordinate distortion via noise | any base + any warp source |

## Style Recipes

| Recipe | Description | Key Technique |
|--------|-------------|---------------|
| **Jagged Mountains** | Craggy mountain terrain | Ridged multifractal + subtle domain warp |
| **Smoky Haze** | Soft volumetric fog | FBM Perlin + light domain warp |
| **Cellular Leather** | Worn leather texture | Worley F2-F1 in UV space |
| **Psychedelic Warp** | Acid-trip swirling patterns | 3x iterative domain warp of FBM |
| **Lava Flow** | Glowing magma cracks | Inverted Worley + domain warp + black body color |
| **Alien Membrane** | Biological horror surfaces | Worley + curl displacement + FBM blend |
| **Crystal Lattice** | Geometric faceted minerals | Worley Chebyshev + quantization |
| **Void Tendrils** | Eldritch dark flow patterns | Curl noise × ridged multifractal |
| **Aurora Bands** | Ethereal sky bands | Anisotropic FBM + gentle warp |
| **Watercolor Wash** | Soft bleeding-edge paint | Value FBM + domain warp + Gabor grain |
| **Circuit Board** | PCB trace lines and pads | Manhattan Worley + step threshold + Chebyshev pads |
| **Deep Ocean Caustics** | Animated underwater light | Dual Worley + animated domain warp |
| **Fungal Growth** | Mycelium tendrils | Curl-advected Worley + ridged multifractal |

## Repository Layout

```
noise_fields/
  pack.json                          # Pack metadata (v0.3.0)
  noise_families/
    index.json                       # Family registry
    perlin.json                      # Gradient noise on a lattice
    simplex.json                     # Improved gradient noise over simplices
    worley.json                      # Cellular / Voronoi noise
    fbm.json                         # Fractal Brownian Motion
    ridged_multifractal.json         # Ridge-sharpened FBM
    domain_warp.json                 # Coordinate distortion
    curl.json                        # Divergence-free vector fields
    value.json                       # Scalar lattice noise (cheap, painterly)
    gabor.json                       # Oriented Gabor kernel convolution
  combinators/
    index.json                       # Combinator registry
    fbm.json / multifractal.json / hybrid_multifractal.json / domain_warp.json
  shaders/
    glsl/                            # Working GLSL implementations
    wgsl/                            # Working WGSL implementations
  recipes/
    index.json                       # Recipe registry
    jagged_mountains.json            # + 12 more recipes
gallery/
  index.html                         # Zero-dependency WebGL interactive gallery
docs/
  architecture.md                    # How the pack is designed
  adding-recipes.md                  # How to extend it
examples/
  psychedelic_fullscreen.glsl        # Standalone IQ-warp demo
  shadertoy_lava.glsl               # ShaderToy lava cracks demo
```

## Interactive Gallery

Open `gallery/index.html` directly in any WebGL2-capable browser — no build step required.

- **10 live recipes** rendered in real-time (60 fps target)
- **Dropdown** to switch between: Perlin FBM, Worley Cells, Domain Warp, Value Wash, Circuit Board, Ocean Caustics, Gabor Fabric, Fungal Growth, Ridged Mountains, Curl Tendrils
- **Sliders** for frequency, octaves, warp strength, orientation, and animation speed
- **6 palettes**: Greyscale, Thermal, Ocean, Forest, Acid, Circuit Green
- All noise implementations are inlined — no external dependencies

## How RepoScripter Uses This

1. **Parse** `noise_families/*.json` to enumerate available types + shader locations
2. **Match** natural-language descriptions to `canonical_parameter_sets` via `style_tags`
3. **Compose** noise graphs following `recipe.noise_graph` for complex styles
4. **Choose** GLSL vs WGSL depending on target runtime
5. **Avoid** failure modes listed in `art_failure_modes`

## Shader Conventions

- GLSL chunks use `#ifndef NOISE_FIELDS_*_GLSL` include guards
- WGSL chunks are standalone function definitions
- Internal helpers prefixed with `_nf_` / `_snf_` / `_wnf_` to avoid collisions
- All base noise functions return values in approx `[-1, 1]`
- Include order: base noise → combinators → modifiers

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). TL;DR: valid JSON, both GLSL + WGSL chunks, update indexes, add style tags.

## License

MIT — see [LICENSE](LICENSE).
