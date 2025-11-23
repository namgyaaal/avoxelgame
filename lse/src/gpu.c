#include <SDL3/SDL.h>

SDL_GPUShader* LSE_CreateGPUShader(SDL_GPUDevice* device,
                                   SDL_GPUShaderCreateInfo* create_info,
                                   const char* entry_point) {
    create_info->entrypoint = entry_point;
    return SDL_CreateGPUShader(device, create_info);
}