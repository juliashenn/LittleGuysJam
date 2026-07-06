shader_type spatial;

render_mode unshaded, blend_mix, cull_back;

uniform vec4 base_color : source_color = vec4(0.8, 0.7, 0.6, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.2, 0.2, 0.4, 1.0);
uniform vec4 highlight_color : source_color = vec4(1.0, 0.95, 0.8, 1.0);
uniform float shadow_threshold = 0.4;
uniform float highlight_threshold = 0.85;
uniform float master_alpha = 1.0;
uniform vec3 light_direction = vec3(1.0, 2.0, 1.0);

varying vec3 world_normal;

void vertex() {
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    float ndotl = clamp(dot(world_normal, normalize(light_direction)), 0.0, 1.0);

    vec4 chosen;
    if (ndotl > highlight_threshold) {
        chosen = highlight_color;
    } else if (ndotl > shadow_threshold) {
        chosen = base_color;
    } else {
        chosen = shadow_color;
    }

    ALBEDO = chosen.rgb;
    ALPHA = chosen.a * master_alpha;
}