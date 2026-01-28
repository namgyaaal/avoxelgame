#version 460

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 uv;

layout (location = 1) out float z_depth;
layout (location = 0) out vec2 out_uv;

layout (std140, set = 3, binding = 0) uniform MVPBlock {
    mat4 mvp;
};

layout (std140, set = 3, binding = 1) uniform ViewBlock {
    mat4 model;
};

void main() {
    gl_Position = mvp * vec4(position, 1.0f);
    out_uv = uv;
    
    vec4 pos = model * vec4(position, 1.0f);
    z_depth = gl_Position.z;
}