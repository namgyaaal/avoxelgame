![Cover](./images/cover.png)

# A Voxel Game

This started off as a bet with myself that APL notation would provide an easier way to make a voxel game.

This is highly experimental and buggy.

## Controls

- W-A-S-D to move
- Space to jump
- Mouse to move the camera
- Q to quit
- I to toggle render information

# Requirements

- Dyalog APL 20.0
- A C Compiler
- CMake
- sdl3, sdl3_ttf and sdl3_image (MacOS with `brew`)

This has been developed on MacOS and Linux should work with minimal changes. Windows will be tested in the near future.

After installing dependencies and cloning, make sure you build and install LSE.
e.g.,
```
cd lse 
mkdir build
cd build
cmake ..
make 
make install
```

This should install `libLSE.dylib` on macOS and `libLSE.so` on Linux in `./libs/`.

Some Linux users may have `dyalogscript` located in a different directory. If that's the case, the shebang in `main.apls` should be replaced with the path specified by `which dyalogscript`

You should be able to run it by doing `./main.apls` after this.

## Compiling Shaders

Source code that gets compiled to different shader formats is in `./shaders/glsl`

Shaders come bundled with this repo. However, if you want to modify them, edit the glsl shaders and run `./compile_shaders.sh` 

Note that this requires glslc and spirv-cross.