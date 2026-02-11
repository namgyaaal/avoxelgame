#version 460

layout (location = 0) in uvec4 position;

layout (location = 1) out float o_z_depth;
layout (location = 0) out vec3 o_uv;

layout (std140, set = 1, binding = 0) uniform MVPBlock {
    mat4 mvp;
};

void main() {
    vec4 pos = vec4(position.x & 0x001F, position.y, position.z & 0x001F, 1.0);
    gl_Position = mvp * pos;
    o_uv = vec3(position.z>>7, position.x>>7, position.w);
    o_z_depth = gl_Position.z;
}