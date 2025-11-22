#!/usr/local/bin/dyalogscript
⎕FIX 'sdl3.apln'
⎕FIX 'lse.apln'

sdl3.load_lib 'libs/libLSE.dylib'
lse.load_lib 'libs/libLSE.dylib'

:If 0 = sdl3.SDL_Init sdl3.SDL_INIT_VIDEO
    ⎕ ← 'Error initializing SDL3' 
    ⎕SIGNAL 200
:Endif

window ← sdl3.SDL_CreateWindow 'Hello World' 900 600 0
:If 0 = window 
    ⎕ ← 'Error creating window for SDL3'
    ⎕SIGNAL 200
:Endif 



running ← 1 
:While running 
    :While ⊃lse.LSE_PollEvent⍬
    :If lse.LSE_CheckEvent 256
        running ← 0
    :Elseif lse.LSE_CheckEvent 768
        key ← ⊃lse.LSE_GetKeyPressed⍬
        :If key = sdl3.SDLK_RETURN
            ⎕ ← 'Pressed the enter key'
        :Endif
    :Elseif lse.LSE_CheckEvent 769
        key ← ⊃lse.LSE_GetKeyPressed⍬
        :If key = sdl3.SDLK_BACKSPACE 
            ⎕ ← 'Released the backspace key'
        :EndIf
    :Elseif lse.LSE_CheckEvent 1024
        ⎕ ← 'Mouse move: ', ⍕lse.LSE_GetMouseMove 0 0
    :EndIf


    :EndWhile

:EndWhile


sdl3.SDL_DestroyWindow window
sdl3.SDL_Quit
