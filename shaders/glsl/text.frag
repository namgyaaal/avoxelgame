#version 460

layout (location = 0) in vec4 color;
layout (location = 1) in vec2 uv;

layout (set = 2, binding = 0) uniform sampler2D sample_tex;

layout (location = 0) out vec4 o_color;

void main() {
    float smoothing = 1.0 / 16.0;
    float distance = texture(sample_tex, uv).a;
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);

    o_color = vec4(color.rgb, color.a * alpha); 
}