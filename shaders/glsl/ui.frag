#version 460

layout (location = 1) in vec3 uv;

layout (set = 2, binding = 0) uniform sampler2DArray sample_tex;

layout (location = 0) out vec4 o_color;

void main() {
    o_color = texture(sample_tex, uv);
}
