#version 460

layout (location = 1) in vec3 uv;
layout (location = 0) out vec4 o_color;

layout (set = 2, binding = 0) uniform sampler2DArray sample_tex;


layout (std140, set = 3, binding = 0) uniform MixInfo {
    vec3 color;
    float id;
};

void main() {
    vec4 t_color = texture(sample_tex, uv);
    if (abs(uv.z - id) < 0.001) {
        o_color = mix(t_color, vec4(color, 1.0), 0.5);
    } else {
        o_color = t_color;
    }
}
