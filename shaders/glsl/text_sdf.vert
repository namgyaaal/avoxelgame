#version 460

layout (location = 0) in vec3 position;
layout (location = 1) in vec4 color;
layout (location = 2) in vec2 uv;

layout (location = 0) out vec4 o_color;
layout (location = 1) out vec2 o_uv;

layout (std140, set = 1, binding = 0) uniform MVPBlock {
    mat4 mvp;
};

void main() {
    o_color = color;
    o_uv = uv;
    gl_Position = mvp * vec4(position, 1.0);
}