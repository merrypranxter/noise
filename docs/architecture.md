# Architecture

## Design Philosophy

`noise_fields` is a **knowledge pack**, not a library. It encodes *semantic understanding* of procedural noise — what each type looks like, what it's good for, how it fails, and what parameter ranges produce specific visual results — alongside working shader implementations.

The key insight: an LLM (like RepoScripter) can parse these JSON descriptors to understand noise at a conceptual level, then assemble concrete shader code by referencing the included GLSL/WGSL chunks.

## Data Flow

```
Natural Language Description
  ↓
RepoScripter parses style_tags + visual_keywords
  ↓
Matches to noise_family + canonical_parameter_set
  ↓
Follows recipe noise_graph for composition
  ↓
Assembles shader chunks (GLSL or WGSL)
  ↓
Concrete shader with tuned parameters
```

## File Organization

### JSON Descriptors (the brain)

Each noise family has a JSON file with a consistent schema:

- `id` / `display_name` — Machine and human identifiers
- `mathematical_definition` — Plain-English math summary for LLM grounding
- `visual_keywords` — Tags the LLM can match against prompts
- `good_for` — Common use-cases
- `art_failure_modes` — How this noise goes wrong (critical for avoiding ugly output)
- `canonical_parameter_sets` — Named presets mapping phrases to numbers
- `shader_chunks` — Pointers to GLSL/WGSL files
- `complexity_notes` — Performance hints

### Combinators (the verbs)

Combinators describe *how* base noises are composed:

- FBM: additive octave stacking
- Multifractal: multiplicative octave combination
- Hybrid Multifractal: blend of additive/multiplicative
- Domain Warp: coordinate distortion

Each has parameter ranges with `typical` values and accepts specific base noise families.

### Recipes (the sentences)

Recipes are complete noise configurations tying:
- A base noise family + parameter preset
- Zero or more modifiers (domain warp, blend, invert, etc.)
- Style tags and example prompts
- Screenshot/rendering metadata

### Shader Chunks (the output)

GLSL and WGSL implementations share identical APIs where possible. All chunks use include guards (GLSL) or are standalone functions (WGSL).

**Include order matters for GLSL:**
1. `perlin.glsl` and/or `simplex.glsl` (base noise)
2. `worley.glsl` (if using cellular noise)
3. `fbm.glsl` (requires base noise)
4. `ridged_multifractal.glsl` (requires base noise)
5. `domain_warp.glsl` (requires simplex)
6. `curl.glsl` (requires simplex)

## Extending the Pack

See [adding-recipes.md](adding-recipes.md) for step-by-step instructions on adding new noise families, parameter presets, and style recipes.
