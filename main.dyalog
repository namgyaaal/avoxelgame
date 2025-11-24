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

device ← sdl3.SDL_CreateGPUDevice sdl3.SDL_GPU_SHADERFORMAT_MSL 1 'metal'
:If 0 = device
    ⎕ ← 'Error creating a GPU device'
    ⎕SIGNAL 200
:Elseif 0 = sdl3.SDL_ClaimWindowForGPUDevice device window
    ⎕ ← 'Error attaching device to window'
    ⎕SIGNAL 200
:Endif

⍝ Create buffers

positions ← ↑(¯0.5 0.5 0.0) (0.5 0.5 0.0) (¯0.5, ¯0.5 0.0) (0.5 ¯0.5 0.0)
colors ← ↑(1 0 0 1) (0 1 0 1) (0 0 1 1) (1 0 1 0)
vertex_data ← ∊positions,colors
vertex_size ← 4 × ≢vertex_data ⍝ in bytes for f32

index_data ← ∊(0 1 2) (1 2 3)
index_size ← 2 × ≢index_data ⍝ in bytes for u16

vb_params ←⊂ sdl3.SDL_GPU_BUFFERUSAGE_VERTEX vertex_size 0
ib_params ←⊂ sdl3.SDL_GPU_BUFFERUSAGE_INDEX index_size 0 

vertex_buffer ← sdl3.SDL_CreateGPUBuffer device vb_params
index_buffer ← sdl3.SDL_CreateGPUBuffer device ib_params
:If (0 = index_buffer) ∨ (0 = vertex_buffer)
    ⎕ ← 'Error creating vertex and index buffers'
    ⎕SIGNAL 200
:Endif

tb_params ← ⊂sdl3.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD (vertex_size + index_size) 0
transfer_buffer ← sdl3.SDL_CreateGPUTransferBuffer device tb_params
:If 0 = transfer_buffer
    ⎕ ← 'Error creating transfer buffer'
    ⎕SIGNAL 200
:Endif

⍝ Copy vertex data into transfer buffer and move to vertex buffer
mem_ptr ← sdl3.SDL_MapGPUTransferBuffer device transfer_buffer 0
lse.LSE_MemcpyF32 (mem_ptr) (vertex_data) vertex_size
lse.LSE_MemcpyU16 (mem_ptr + vertex_size) (index_data) index_size

cmd_buf ← sdl3.SDL_AcquireGPUCommandBuffer device
pass ← sdl3.SDL_BeginGPUCopyPass cmd_buf
sdl3.SDL_UploadToGPUBuffer pass (transfer_buffer 0) (vertex_buffer 0 vertex_size) 0
sdl3.SDL_UploadToGPUBuffer pass (transfer_buffer vertex_size) (index_buffer 0 index_size) 0
sdl3.SDL_EndGPUCopyPass pass 
sdl3.SDL_SubmitGPUCommandBuffer cmd_buf


⍝ Load shaders
v_src v_size ← sdl3.SDL_LoadFile 'shaders/vertex.msl' 0
f_src f_size ← sdl3.SDL_LoadFile 'shaders/fragment.msl' 0

:If (0 = v_src) ∨ (0 = f_src) 
    ⎕ ← 'Error loading shaders'
    ⎕SIGNAL 200
:Endif
v_info ← v_size v_src 0 sdl3.SDL_GPU_SHADERFORMAT_MSL sdl3.SDL_GPU_SHADERSTAGE_VERTEX 0 0 0 0 0
f_info ← f_size f_src 0 sdl3.SDL_GPU_SHADERFORMAT_MSL sdl3.SDL_GPU_SHADERSTAGE_FRAGMENT 0 0 0 0 0

v_shader ← lse.LSE_CreateGPUShader device v_info 'vertex_main'
f_shader ← lse.LSE_CreateGPUShader device f_info 'fragment_main'
:If (0 = v_src) ∨ (0 = f_src)
    ⎕ ← 'Error creating shaders'
    ⎕SIGNAL 200
:Endif


⍝ Create a render pipeline
lse.LSE_PipelineClearParams⍬
lse.LSE_PipelineSetShaders v_shader f_shader
⍝ Vertex Buffer Descriptions and Attributes : Vertex Input
vb_desc ←⊂ (0 (4 × 7) 0 0)
vb_attr ←⊂ (0 0 sdl3.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3 0) 
vb_attr,←⊂ (1 0 sdl3.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4 (4 × 3))
lse.LSE_PipelineSetVertexInput (⊂vb_desc), 1, (⊂vb_attr), 2

⍝ Color Targets
default_format ← ⊃sdl3.SDL_GetGPUSwapchainTextureFormat device window


blend_state ← sdl3.SDL_GPU_BLENDFACTOR_SRC_ALPHA
blend_state,← sdl3.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA
blend_state,← sdl3.SDL_GPU_BLENDOP_ADD
⍝ 0's - padding, writemask, etc
⍝ Duplicate alpha and color blendfactors and blendops
blend_state ← (5⍴0),⍨6⍴ blend_state
ct_desc ← ⊂default_format blend_state

lse.LSE_PipelineSetTargetInfo (⊂ct_desc), 1 0 0
pipeline ← lse.LSE_PipelineCreate device
:If 0 = pipeline
    ⎕ ← 'Error creating render pipeline'
    ⎕SIGNAL 200
:Endif

running ← 1
:While running
    :While ⊃lse.LSE_PollEvent⍬
        :If lse.LSE_CheckEvent sdl3.SDL_EVENT_QUIT
            running ← 0
        :Elseif lse.LSE_CheckEvent sdl3.SDL_EVENT_KEY_DOWN
            key ← ⊃lse.LSE_GetKeyPressed⍬
            :If key = sdl3.SDLK_RETURN
                ⎕ ← 'Pressed the enter key'
            :Endif
        :Elseif lse.LSE_CheckEvent sdl3.SDL_EVENT_KEY_UP
            key ← ⊃lse.LSE_GetKeyPressed⍬
            :If key = sdl3.SDLK_BACKSPACE
                ⎕ ← 'Released the backspace key'
            :EndIf
        :Elseif lse.LSE_CheckEvent sdl3.SDL_EVENT_MOUSE_MOTION
            ⍝⎕ ← 'Mouse move: ', ⍕lse.LSE_GetMouseMove 0 0
        :EndIf
    :EndWhile

    cmd_buf ← sdl3.SDL_AcquireGPUCommandBuffer device
    res texture width height ← sdl3.SDL_WaitAndAcquireGPUSwapchainTexture cmd_buf window 0 0 0
    :If 0 = res
        ⎕ ← 'Error acquiring swapchain texture'
        ⎕SIGNAL 200
    :EndIf
    color_info ← ⊂(texture 0 0 (0.1 0.2 0.3 1) 1 0 0 0 0 0 0 0 0)
    pass ← sdl3.SDL_BeginGPURenderPass cmd_buf color_info 1 0

    sdl3.SDL_BindGPUGraphicsPipeline pass pipeline

    vbuffer_list ← ⊂(vertex_buffer 0)
    ibuffer_list ← ⊂(index_buffer 0)

    sdl3.SDL_BindGPUVertexBuffers pass 0 vbuffer_list 1
    sdl3.SDL_BindGPUIndexBuffer pass ibuffer_list sdl3.SDL_GPU_INDEXELEMENTSIZE_16BIT
    sdl3.SDL_DrawGPUIndexedPrimitives pass 6 1 0 0 0
    sdl3.SDL_EndGPURenderPass pass
    sdl3.SDL_SubmitGPUCommandBuffer cmd_buf

:EndWhile

sdl3.SDL_ReleaseGPUShader device v_shader
sdl3.SDL_ReleaseGPUShader device f_shader

sdl3.SDL_ReleaseGPUGraphicsPipeline device pipeline

sdl3.SDL_ReleaseGPUTransferBuffer device transfer_buffer
sdl3.SDL_ReleaseGPUBuffer device index_buffer
sdl3.SDL_ReleaseGPUBuffer device vertex_buffer

sdl3.SDL_DestroyGPUDevice device
sdl3.SDL_DestroyWindow window
sdl3.SDL_Quit
