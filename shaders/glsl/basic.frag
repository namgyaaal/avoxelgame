#version 460

layout (set = 2, binding = 0) uniform sampler2D sampleTex;

layout (location = 0) in vec2 in_uv;
layout (location = 1) in float in_z_depth;

layout (location = 0) out vec4 out_color;

float fog_start = 30.0;
float fog_end = 50.0;
vec4 fog_color = vec4(0.47, 0.48, 0.49, 1.0);

void main() {
    float fog_factor = (fog_end - in_z_depth) / (fog_end - fog_start);
    fog_factor = clamp(fog_factor, 0.0, 1.0);
    out_color = mix(fog_color, texture(sampleTex, in_uv), fog_factor);
}