#version 460

layout (location = 0) in vec4 color;
layout (location = 1) in vec2 uv;


layout (set = 2, binding = 0) uniform sampler2D sample_tex;


layout (location = 0) out vec4 o_color;
void main() {
    o_color = color * texture(sample_tex, uv);
}
