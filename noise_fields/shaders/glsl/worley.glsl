// shaders/glsl/worley.glsl
// Worley (cellular) noise, 2D/3D variants.
// Based on Stefan Gustavson's cellular noise and IQ's implementations.
// Adapted for noise_fields pack.

#ifndef NOISE_FIELDS_WORLEY_GLSL
#define NOISE_FIELDS_WORLEY_GLSL

// --- Internal: hash for cell-based random point placement ---

vec3 _nf_worleyHash3(vec3 p) {
    p = vec3(
        dot(p, vec3(127.1, 311.7, 74.7)),
        dot(p, vec3(269.5, 183.3, 246.1)),
        dot(p, vec3(113.5, 271.9, 124.6))
    );
    return fract(sin(p) * 43758.5453123);
}

vec2 _nf_worleyHash2(vec2 p) {
    p = vec2(
        dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3))
    );
    return fract(sin(p) * 43758.5453);
}

// --- 2D Worley: returns vec2(F1, F2) distances ---

vec2 _nf_worley2D(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);

    float d1 = 8.0; // F1
    float d2 = 8.0; // F2

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = _nf_worleyHash2(n + g);
            vec2 r = g + o - f;
            float d = dot(r, r);
            if (d < d1) {
                d2 = d1;
                d1 = d;
            } else if (d < d2) {
                d2 = d;
            }
        }
    }

    return sqrt(vec2(d1, d2));
}

// 2D Worley noise returning F1 distance (nearest cell center)
float worleyF1_2D(vec2 p) {
    return _nf_worley2D(p).x;
}

// 2D Worley noise returning F2 distance (second nearest)
float worleyF2_2D(vec2 p) {
    return _nf_worley2D(p).y;
}

// 2D Worley noise returning F2 - F1 (cell edge detection)
float worleyF2minusF1_2D(vec2 p) {
    vec2 f = _nf_worley2D(p);
    return f.y - f.x;
}

// --- 3D Worley: returns vec2(F1, F2) distances ---

vec2 _nf_worley3D(vec3 p) {
    vec3 n = floor(p);
    vec3 f = fract(p);

    float d1 = 8.0;
    float d2 = 8.0;

    for (int k = -1; k <= 1; k++) {
        for (int j = -1; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                vec3 g = vec3(float(i), float(j), float(k));
                vec3 o = _nf_worleyHash3(n + g);
                vec3 r = g + o - f;
                float d = dot(r, r);
                if (d < d1) {
                    d2 = d1;
                    d1 = d;
                } else if (d < d2) {
                    d2 = d;
                }
            }
        }
    }

    return sqrt(vec2(d1, d2));
}

// 3D Worley noise returning F1 distance
float worleyF1_3D(vec3 p) {
    return _nf_worley3D(p).x;
}

// 3D Worley noise returning F2 - F1
float worleyF2minusF1_3D(vec3 p) {
    vec2 f = _nf_worley3D(p);
    return f.y - f.x;
}

// --- Manhattan / Chebyshev metric variants for extra weirdness ---

float worleyF1_2D_manhattan(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float d1 = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = _nf_worleyHash2(n + g);
            vec2 r = g + o - f;
            float d = abs(r.x) + abs(r.y); // Manhattan
            d1 = min(d1, d);
        }
    }
    return d1;
}

float worleyF1_2D_chebyshev(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float d1 = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = _nf_worleyHash2(n + g);
            vec2 r = g + o - f;
            float d = max(abs(r.x), abs(r.y)); // Chebyshev
            d1 = min(d1, d);
        }
    }
    return d1;
}

#endif
