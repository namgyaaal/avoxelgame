#include <SDL3/SDL.h>
#include <stdlib.h>

/*
    SDL_Event is a tagged union that would be very difficult to handle in APL.

    Solve this by creating helper functions that manage the state of it.
*/

SDL_Event global_event;

bool LSE_PollEvent() { return SDL_PollEvent(&global_event); }

bool LSE_CheckEvent(SDL_EventType type) { return global_event.type == type; }

SDL_Keycode LSE_GetKeyPressed() { return global_event.key.key; }

void LSE_GetMouseMove(int32_t* x, int32_t* y) {
    *x = global_event.motion.x;
    *y = global_event.motion.y;
}

void LSE_GetMouseMoveRel(int32_t* xrel, int32_t* yrel) {
    *xrel = global_event.motion.xrel;
    *yrel = global_event.motion.yrel;
}

uint8_t LSE_GetButton() { return global_event.button.button; }