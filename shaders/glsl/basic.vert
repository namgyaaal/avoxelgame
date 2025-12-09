#version 460

layout (location = 0) in vec3 position;
layout (location = 1) in vec4 color;
layout (location = 2) in vec2 uv;

layout (location = 0) out vec4 out_color;
layout (location = 1) out vec2 out_uv;

layout (std140, set = 3, binding = 0) uniform UniformBlock {
    mat4 mvp;
};

void main() {
    gl_Position = mvp * vec4(position, 1.0f);
    out_color = color;
    out_uv = uv;
}