#include <SDL3/SDL.h>
#include <stdio.h>

/*
    I don't think APL's ⎕NA supports pointers to a struct with pointers without
   using `P` so this is just a set of helper functions to help split up the
   different parameters of the GraphicsPipeline.

   Also makes it less likely for me to have bugs in the creation process.
*/

SDL_GPUGraphicsPipelineCreateInfo global_params;

/*
    From personal testing, if you pass a function with an input pointer type
   (e.g., <{U4 U4}[]), you will only be guaranteed ownership of it for the
   duration of the function.

    For VertexInput & ColorTarget Descriptions, copy them into these buffers to
   avoid this.
*/

SDL_GPUVertexBufferDescription vb_descriptions[16];
SDL_GPUVertexAttribute vb_attributes[16];
SDL_GPUColorTargetDescription ct_descriptions[16];

void LSE_PipelineClearParams() {
    SDL_memset(&global_params, 0, sizeof(global_params));
}

SDL_GPUGraphicsPipeline* LSE_PipelineCreate(SDL_GPUDevice* device) {
    return SDL_CreateGPUGraphicsPipeline(device, &global_params);
}

void LSE_PipelineSetShaders(SDL_GPUShader* vertex_shader,
                            SDL_GPUShader* fragment_shader) {
    global_params.vertex_shader = vertex_shader;
    global_params.fragment_shader = fragment_shader;
}

void LSE_PipelineSetVertexInput(SDL_GPUVertexBufferDescription* desc,
                                uint32_t num_vertex_buffers,
                                SDL_GPUVertexAttribute* attrib,
                                uint32_t num_vertex_attributes) {
    SDL_GPUVertexInputState state;
    state.num_vertex_buffers = num_vertex_buffers;
    for (int i = 0; i < num_vertex_buffers; i++) {
        vb_descriptions[i] = desc[i];
    }
    state.vertex_buffer_descriptions = vb_descriptions;

    state.num_vertex_attributes = num_vertex_attributes;
    for (int i = 0; i < num_vertex_attributes; i++) {
        vb_attributes[i] = attrib[i];
    }
    state.vertex_attributes = vb_attributes;

    global_params.vertex_input_state = state;
}

void LSE_PipelineSetPrimitive(SDL_GPUPrimitiveType type) {
    global_params.primitive_type = type;
}

void LSE_PipelineSetRasterizer(SDL_GPUFillMode fill_mode,
                               SDL_GPUCullMode cull_mode,
                               SDL_GPUFrontFace front_face,
                               float depth_bias_constant_factor,
                               float depth_bias_clamp,
                               float depth_bias_slope_factor,
                               bool enable_depth_bias, bool enable_depth_clip) {
    SDL_GPURasterizerState state;
    state.fill_mode = fill_mode;
    state.cull_mode = cull_mode;
    state.front_face = front_face;
    state.depth_bias_constant_factor = depth_bias_constant_factor;
    state.depth_bias_clamp = depth_bias_clamp;
    state.depth_bias_slope_factor = depth_bias_slope_factor;
    state.enable_depth_bias = enable_depth_bias;
    state.enable_depth_clip = enable_depth_clip;
    global_params.rasterizer_state = state;
}

void LSE_PipelineSetMultisample(SDL_GPUSampleCount sample_count,
                                uint32_t sample_mask, bool enable_mask,
                                bool enable_alpha_to_coverage) {
    SDL_GPUMultisampleState state;
    state.sample_count = sample_count;
    state.sample_mask = sample_mask;
    state.enable_mask = enable_mask;
    global_params.multisample_state = state;
}

void LSE_PipelineSetDepthStencil(SDL_GPUCompareOp compare_op,
                                 SDL_GPUStencilOpState back_stencil_state,
                                 SDL_GPUStencilOpState front_stencil_state,
                                 uint8_t compare_mask, uint8_t write_mask,
                                 bool enable_depth_test,
                                 bool enable_depth_write,
                                 bool enable_stencil_test) {
    SDL_GPUDepthStencilState state = {.compare_op = SDL_GPU_COMPAREOP_LESS,
                                      .enable_depth_test = true,
                                      .enable_depth_write = true};

    global_params.depth_stencil_state.compare_op = compare_op;
    global_params.depth_stencil_state.back_stencil_state = back_stencil_state;
    global_params.depth_stencil_state.front_stencil_state = front_stencil_state;
    global_params.depth_stencil_state.compare_mask = compare_mask;
    global_params.depth_stencil_state.write_mask = write_mask;
    global_params.depth_stencil_state.enable_depth_test = enable_depth_test;
    global_params.depth_stencil_state.enable_depth_write = enable_depth_write;
    global_params.depth_stencil_state.enable_stencil_test = enable_stencil_test;

    global_params.depth_stencil_state = state;
}

void LSE_PipelineSetTargetInfo(
    SDL_GPUColorTargetDescription* color_target_descriptions,
    uint32_t num_color_targets, SDL_GPUTextureFormat depth_stencil_format,
    bool has_depth_stencil_target) {
    SDL_GPUGraphicsPipelineTargetInfo info;

    info.num_color_targets = num_color_targets;
    for (int i = 0; i < num_color_targets; i++) {
        ct_descriptions[i] = color_target_descriptions[i];
    }
    info.color_target_descriptions = ct_descriptions;

    info.depth_stencil_format = depth_stencil_format;
    info.has_depth_stencil_target = has_depth_stencil_target;

    global_params.target_info = info;
}

void LSE_PipelineSetProperties(SDL_PropertiesID properties) {
    global_params.props = properties;
}
