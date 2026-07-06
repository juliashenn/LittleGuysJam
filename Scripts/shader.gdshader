shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.8, 0.7, 0.6, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.114, 0.15, 0.27, 1.0);
uniform vec4 highlight_color : source_color = vec4(1.0, 0.95, 0.8, 1.0);

uniform float shadow_threshold = 0.4;
uniform float highlight_threshold = 0.85;
uniform float master_alpha = 1.0;

void fragment() {
    ALBEDO = shadow_color.rgb;
    ALPHA = master_alpha;
}

void light() {
    float ndotl = max(dot(NORMAL, LIGHT), 0.0);

    if (ndotl > highlight_threshold) {
        DIFFUSE_LIGHT += highlight_color.rgb * LIGHT_COLOR * ATTENUATION;
    } else if (ndotl > shadow_threshold) {
        DIFFUSE_LIGHT += base_color.rgb * LIGHT_COLOR * ATTENUATION;
    }
}
