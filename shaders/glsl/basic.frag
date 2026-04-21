#version 460

layout (set = 2, binding = 0) uniform sampler2DArray sample_tex;

layout (location = 0) in vec3 uv;
layout (location = 1) in float z_depth;

layout (location = 0) out vec4 o_color;

layout (std140, set = 3, binding = 0) uniform FogInfo {
    float fog_start;
    float fog_end;
};

vec4 fog_color = vec4(0.47, 0.48, 0.49, 1.0);

void main() {
    float fog_factor = (fog_end - z_depth) / (fog_end - fog_start);
    fog_factor = clamp(fog_factor, 0.0, 1.0);
    o_color = mix(fog_color, texture(sample_tex, vec3(uv)), fog_factor);
}