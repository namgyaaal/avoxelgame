#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
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

void LSE_FontGPUCopy(void* dst, TTF_GPUAtlasDrawSequence* sequence,
                     uint32_t* vb_count, uint32_t* ib_count, float r, float g,
                     float b, float a, uint32_t MAX_VERTICES,
                     uint32_t vertex_offset, uint32_t index_offset) {
    *vb_count = 0;
    *ib_count = 0;
    float* dst_ptr_vb = ((float*)dst) + (9 * vertex_offset);
    int* dst_ptr_ib = ((int*)dst) + (9 * MAX_VERTICES) + index_offset;
    for (; sequence; sequence = sequence->next) {
        for (int i = 0; i < sequence->num_vertices; i++) {
            // Positions
            *dst_ptr_vb++ = sequence->xy[i].x;
            *dst_ptr_vb++ = sequence->xy[i].y;
            *dst_ptr_vb++ = -10.0f;
            // Color
            *dst_ptr_vb++ = r;
            *dst_ptr_vb++ = g;
            *dst_ptr_vb++ = b;
            *dst_ptr_vb++ = a;
            // UV
            *dst_ptr_vb++ = sequence->uv[i].x;
            *dst_ptr_vb++ = sequence->uv[i].y;
        }
        memcpy(dst_ptr_ib, sequence->indices,
               sizeof(int) * sequence->num_indices);
        dst_ptr_ib += sequence->num_indices;

        *vb_count += sequence->num_vertices;
        *ib_count += sequence->num_indices;
    }
}

void LSE_FontGPUDraw(SDL_GPURenderPass* pass, SDL_GPUSampler* sampler,
                     TTF_GPUAtlasDrawSequence* sequence, uint32_t vertex_offset,
                     uint32_t index_offset) {
    for (TTF_GPUAtlasDrawSequence* seq = sequence; seq != NULL;
         seq = seq->next) {
        SDL_BindGPUFragmentSamplers(
            pass, 0,
            &(SDL_GPUTextureSamplerBinding){.texture = seq->atlas_texture,
                                            .sampler = sampler},
            1);

        SDL_DrawGPUIndexedPrimitives(pass, seq->num_indices, 1, index_offset,
                                     vertex_offset, 0);
        index_offset += seq->num_indices;
        vertex_offset += seq->num_vertices;
    }
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

SDL_GPURenderPass* LSE_BeginDepthLessRenderPass(SDL_GPUCommandBuffer* buf,
                                                SDL_GPUColorTargetInfo* info,
                                                uint32_t num_targets) {
    return SDL_BeginGPURenderPass(buf, info, num_targets, NULL);
}
