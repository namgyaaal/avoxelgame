#include <SDL3/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void LSE_PrintError(const char* err_str) {
    if (strlen(err_str) == 0) {
        printf("No Error\n");
    } else {
        printf("Error: %s\n", err_str);
    }
}

void* LSE_GetSurfaceDataAddress(SDL_Surface* surface) {
    return surface->pixels;
}

void LSE_GetSurfaceParams(SDL_Surface* surface, int* width, int* height,
                          int* pitch, int* format) {
    *width = surface->w;
    *height = surface->h;
    *pitch = surface->pitch;
    *format = surface->format;
}

void LSE_MemcpyU8(void* dst, void* src, uint32_t size) {
    SDL_memcpy(dst, src, size);
}

void LSE_MemcpyU16(void* dst, void* src, uint32_t size) {
    SDL_memcpy(dst, src, size);
}

void LSE_MemcpyU32(void* dst, void* src, uint32_t size) {
    SDL_memcpy(dst, src, size);
}

void LSE_MemcpyF32(void* dst, void* src, uint32_t size) {
    SDL_memcpy(dst, src, size);
}

void LSE_DrawList(SDL_GPURenderPass* pass, SDL_GPUBuffer** buffers,
                  uint32_t* indices, uint32_t buffer_count) {
    for (int i = 0; i < buffer_count; i++) {
        SDL_GPUBufferBinding binding;
        binding.buffer = buffers[i];
        binding.offset = 0;

        SDL_BindGPUVertexBuffers(pass, 0, &binding, 1);
        SDL_DrawGPUIndexedPrimitives(pass, indices[i], 1, 0, 0, 0);
    }
}

void LSE_DrawListWithPushConstants(SDL_GPUCommandBuffer* buf,
                                   SDL_GPURenderPass* pass,
                                   SDL_GPUBuffer** buffers, uint32_t* indices,
                                   uint32_t buffer_count,
                                   float* push_constant_data, uint32_t slot,
                                   uint32_t stride) {
    for (int i = 0; i < buffer_count; i++) {
        SDL_GPUBufferBinding binding;
        binding.buffer = buffers[i];
        binding.offset = 0;

        SDL_PushGPUVertexUniformData(buf, 0, &push_constant_data[i * stride],
                                     stride * sizeof(float));
        SDL_BindGPUVertexBuffers(pass, 0, &binding, 1);
        SDL_DrawGPUIndexedPrimitives(pass, indices[i], 1, 0, 0, 0);
    }
}