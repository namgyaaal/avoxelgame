#version 460

layout (location = 0) in vec3 position;
layout (location = 1) in vec4 color;
layout (location = 0) out vec4 out_color;

layout (std140, set = 3, binding = 0) uniform UniformBlock {
    mat4 model;
};

void main() {
    gl_Position = model * vec4(position, 1.0f);
    out_color = color;
}