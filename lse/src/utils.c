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

void LSE_MemcpyU16(void* dst, void* src, uint32_t size) {
    SDL_memcpy(dst, src, size);
}

void LSE_MemcpyF32(void* dst, void* src, uint32_t size) {
    SDL_memcpy(dst, src, size);
}
