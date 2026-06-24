#version 460

layout (location = 0) in vec3 position;
layout (location = 1) in vec4 color;

layout (location = 0) out vec4 o_color;

layout (std140, set = 1, binding = 0) uniform MVPBlock {
    mat4 mvp;
};

void main() {
    o_color = color;
    gl_Position = mvp * vec4(position, 1.0);
}