#!/bin/bash

# TODO: Once I convert to Dyalog 20.0, replace this with a dyalogscript and ⎕SHELL

if ! [ -x "$(command -v glslc)" ]; then
    echo "glslc is needed in your environment"
    exit 1
fi

if ! [ -x "$(command -v spirv-cross)" ]; then
    echo "spirv-cross is needed in your environment"
    exit 1
fi

if [ ! -d "shaders/glsl" ]; then
    echo "Expect a directory of shaders at 'shaders/glsl'"
    exit 1
fi


mkdir -p shaders/hlsl shaders/spv shaders/msl
rm -f shaders/hlsl/* shaders/spv/* shaders/msl/*

# Vertex shaders
for vertex_file in shaders/glsl/*.vert; do
    stem=$(basename -- $vertex_file .vert)
    spv_file="shaders/spv/${stem}_vert.spv"
    msl_file="shaders/msl/${stem}_vert.msl"
    hlsl_file="shaders/hlsl/${stem}_vert.hlsl"

    glslc -fshader-stage=vertex $vertex_file -o $spv_file
    spirv-cross $spv_file --stage vert --msl --output $msl_file
    spirv-cross $spv_file --stage vert --hlsl --output $hlsl_file
done

# Fragment Shaders
for fragment_file in shaders/glsl/*.frag; do
    stem=$(basename -- $fragment_file .frag)
    spv_file="shaders/spv/${stem}_frag.spv"
    msl_file="shaders/msl/${stem}_frag.msl"
    hlsl_file="shaders/hlsl/${stem}_frag.hlsl"

    glslc -fshader-stage=fragment $fragment_file -o $spv_file
    spirv-cross $spv_file --stage frag --msl --output $msl_file
    spirv-cross $spv_file --stage frag --hlsl --output $hlsl_file
done

echo "Compilation completed"