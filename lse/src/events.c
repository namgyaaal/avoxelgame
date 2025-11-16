#include <SDL3/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

SDL_Event global_event;

bool LSE_PollEvent() {
    SDL_PollEvent(&global_event);
    if (global_event.type == SDL_EVENT_QUIT) {
        return true;
    }
    return false;
}