#include <SDL3/SDL.h>

SDL_GPUShader* LSE_CreateGPUShader(SDL_GPUDevice* device,
                                   SDL_GPUShaderCreateInfo* create_info,
                                   const char* entry_point) {
    create_info->entrypoint = entry_point;
    return SDL_CreateGPUShader(device, create_info);
}

SDL_GPURenderPass* LSE_BeginGPURenderPass(SDL_GPUCommandBuffer* cmd,
                                          SDL_GPUTexture* swap,
                                          SDL_GPUTexture* depth) {
    SDL_GPUColorTargetInfo color_info = {
        .texture = swap,
        .clear_color = {.r = .1, .g = .2, .b = .3, .a = 1.0},
        .load_op = SDL_GPU_LOADOP_CLEAR};

    SDL_GPUDepthStencilTargetInfo depth_info = {
        .texture = depth,
        .load_op = SDL_GPU_LOADOP_CLEAR,
        .clear_depth = 1.0,
        .store_op = SDL_GPU_STOREOP_DONT_CARE};

    return SDL_BeginGPURenderPass(cmd, &color_info, 1, &depth_info);
}