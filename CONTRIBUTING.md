# Contributing to noise_fields

## Quick Checklist

- [ ] JSON files are valid (run `python3 -m json.tool your_file.json`)
- [ ] New families have both GLSL and WGSL shader chunks
- [ ] New entries are added to the appropriate `index.json`
- [ ] Recipes have at least 4 style tags and 2 example prompts
- [ ] Parameter presets have meaningful `style_tags`

## What to Contribute

### High Value
- **New noise families** (e.g., Value noise, Blue noise, Gabor noise)
- **New recipes** with unique visual aesthetics
- **More canonical parameter presets** on existing families
- **Additional shader variants** (different metrics, anisotropic versions)
- **Bug fixes** in shader implementations

### Always Welcome
- Better `art_failure_modes` descriptions
- More `visual_keywords` and `style_tags`
- Example shaders for existing recipes
- Documentation improvements

## Style Guide

### JSON
- 2-space indentation
- IDs use `snake_case`
- Style tags are lowercase
- Descriptions are one sentence

### Shaders
- GLSL: Use `#ifndef` include guards prefixed with `NOISE_FIELDS_`
- WGSL: Standalone functions, no module syntax
- Internal helpers prefixed with `_nf_` or `_wnf_` etc. to avoid collisions
- Comment the algorithm origin/reference

## Validation

Run locally before PR:
```bash
find noise_fields -name "*.json" -exec python3 -m json.tool {} \; > /dev/null
```

CI will also check JSON syntax, index completeness, and shader file references on every PR.
