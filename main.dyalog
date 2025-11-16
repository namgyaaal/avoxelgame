⎕FIX 'sdl3.apln'
⎕FIX 'lse.apln'

sdl3.load_lib

:If 0 = sdl3.SDL_Init 32 
    ⎕ ← 'Error initializing SDL3' 
:Endif

window ← sdl3.SDL_CreateWindow 'Hello World' 900 600 0
:If 0 = window 
    ⎕ ← 'Error creating window for SDL3'
:Endif 

sdl3.SDL_PumpEvents
⎕DL 10


sdl3.SDL_DestroyWindow window
sdl3.SDL_Quit
