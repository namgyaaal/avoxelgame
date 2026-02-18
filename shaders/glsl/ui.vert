#version 460

layout (location = 0) in vec2 position;
layout (location = 1) in vec3 uv;

layout (location = 1) out vec3 o_uv;

layout (std140, set = 1, binding = 0) uniform MVPBlock {
    mat4 mvp;
};

void main() {
    o_uv = uv;
    gl_Position = mvp * vec4(position, -20.0, 1.0);
}