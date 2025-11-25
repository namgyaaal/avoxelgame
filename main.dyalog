#!/usr/local/bin/dyalogscript
⎕SE.(⍎⊃2⎕FIX'/StartupSession.aplf',⍨2⎕NQ # 'GetEnvironment' 'DYALOG')
⎕SE.Link.Create 'lagl' './lagl'

lagl.sdl3.load_lib 'libs/libLSE.dylib'
lagl.lse.load_lib 'libs/libLSE.dylib'

:If 0 = lagl.SDL_Init lagl.SDL_INIT_VIDEO
    ⎕ ← 'Error initializing SDL3'
    ⎕SIGNAL 200
:Endif

window ← lagl.SDL_CreateWindow 'Hello World' 900 600 0
:If 0 = window
    ⎕ ← 'Error creating window for SDL3'
    ⎕SIGNAL 200
:Endif

device ← lagl.SDL_CreateGPUDevice lagl.SDL_GPU_SHADERFORMAT_MSL 1 'metal'
:If 0 = device
    ⎕ ← 'Error creating a GPU device'
    ⎕SIGNAL 200
:Elseif 0 = lagl.SDL_ClaimWindowForGPUDevice device window
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

vb_params ←⊂ lagl.SDL_GPU_BUFFERUSAGE_VERTEX vertex_size 0
ib_params ←⊂ lagl.SDL_GPU_BUFFERUSAGE_INDEX index_size 0 

vertex_buffer ← lagl.SDL_CreateGPUBuffer device vb_params
index_buffer ← lagl.SDL_CreateGPUBuffer device ib_params
:If (0 = index_buffer) ∨ (0 = vertex_buffer)
    ⎕ ← 'Error creating vertex and index buffers'
    ⎕SIGNAL 200
:Endif

tb_params ← ⊂lagl.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD (vertex_size + index_size) 0
transfer_buffer ← lagl.SDL_CreateGPUTransferBuffer device tb_params
:If 0 = transfer_buffer
    ⎕ ← 'Error creating transfer buffer'
    ⎕SIGNAL 200
:Endif

⍝ Copy vertex data into transfer buffer and move to vertex buffer
mem_ptr ← lagl.SDL_MapGPUTransferBuffer device transfer_buffer 0
lagl.LSE_MemcpyF32 (mem_ptr) (vertex_data) vertex_size
lagl.LSE_MemcpyU16 (mem_ptr + vertex_size) (index_data) index_size

cmd_buf ← lagl.SDL_AcquireGPUCommandBuffer device
pass ← lagl.SDL_BeginGPUCopyPass cmd_buf
lagl.SDL_UploadToGPUBuffer pass (transfer_buffer 0) (vertex_buffer 0 vertex_size) 0
lagl.SDL_UploadToGPUBuffer pass (transfer_buffer vertex_size) (index_buffer 0 index_size) 0
lagl.SDL_EndGPUCopyPass pass 
lagl.SDL_SubmitGPUCommandBuffer cmd_buf


⍝ Load shaders
v_src v_size ← lagl.SDL_LoadFile 'shaders/vertex.msl' 0
f_src f_size ← lagl.SDL_LoadFile 'shaders/fragment.msl' 0

:If (0 = v_src) ∨ (0 = f_src) 
    ⎕ ← 'Error loading shaders'
    ⎕SIGNAL 200
:Endif
v_info ← v_size v_src 0 lagl.SDL_GPU_SHADERFORMAT_MSL lagl.SDL_GPU_SHADERSTAGE_VERTEX 0 0 0 1 0
f_info ← f_size f_src 0 lagl.SDL_GPU_SHADERFORMAT_MSL lagl.SDL_GPU_SHADERSTAGE_FRAGMENT 0 0 0 0 0

v_shader ← lagl.LSE_CreateGPUShader device v_info 'vertex_main'
f_shader ← lagl.LSE_CreateGPUShader device f_info 'fragment_main'
:If (0 = v_src) ∨ (0 = f_src)
    ⎕ ← 'Error creating shaders'
    ⎕SIGNAL 200
:Endif


⍝ Create a render pipeline
lagl.LSE_PipelineClearParams⍬
lagl.LSE_PipelineSetShaders v_shader f_shader
⍝ Vertex Buffer Descriptions and Attributes : Vertex Input
vb_desc ←⊂ (0 (4 × 7) 0 0)
vb_attr ←⊂ (0 0 lagl.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3 0) 
vb_attr,←⊂ (1 0 lagl.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4 (4 × 3))
lagl.LSE_PipelineSetVertexInput (⊂vb_desc), 1, (⊂vb_attr), 2

⍝ Color Targets
default_format ← ⊃lagl.SDL_GetGPUSwapchainTextureFormat device window


blend_state ← lagl.SDL_GPU_BLENDFACTOR_SRC_ALPHA
blend_state,← lagl.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA
blend_state,← lagl.SDL_GPU_BLENDOP_ADD
⍝ 0's - padding, writemask, etc
⍝ Duplicate alpha and color blendfactors and blendops
blend_state ← (5⍴0),⍨6⍴ blend_state
ct_desc ← ⊂default_format blend_state

lagl.LSE_PipelineSetTargetInfo (⊂ct_desc), 1 0 0
pipeline ← lagl.LSE_PipelineCreate device
:If 0 = pipeline
    ⎕ ← 'Error creating render pipeline'
    ⎕SIGNAL 200
:Endif

(x_dir y_dir x_pos y_pos) ← 0 0 0 0


running ← 1
:While running
    :While ⊃lagl.LSE_PollEvent⍬
        :If lagl.LSE_CheckEvent lagl.SDL_EVENT_QUIT
            running ← 0
        :Elseif lagl.LSE_CheckEvent lagl.SDL_EVENT_KEY_DOWN
            key ← ⊃lagl.LSE_GetKeyPressed⍬
            :If key = lagl.SDLK_RETURN
                ⎕ ← 'Pressed the enter key'
            :Elseif key = lagl.SDLK_D
                x_dir ← 1
            :Elseif key = lagl.SDLK_A
                x_dir ← ¯1
            :Elseif key = lagl.SDLK_W
                y_dir ← 1
            :Elseif key = lagl.SDLK_S
                y_dir ← ¯1
            :Endif
        :Elseif lagl.LSE_CheckEvent lagl.SDL_EVENT_KEY_UP
            key ← ⊃lagl.LSE_GetKeyPressed⍬
            :If key = lagl.SDLK_BACKSPACE
                ⎕ ← 'Released the backspace key'
            :Elseif key = lagl.SDLK_D
                x_dir ← 0
            :Elseif key = lagl.SDLK_A
                x_dir ← 0
            :Elseif key = lagl.SDLK_W
                y_dir ← 0
            :Elseif key = lagl.SDLK_S
                y_dir ← 0
            :Endif
        :Elseif lagl.LSE_CheckEvent lagl.SDL_EVENT_MOUSE_MOTION
            ⍝⎕ ← 'Mouse move: ', ⍕lagl.LSE_GetMouseMove 0 0
        :EndIf
    :EndWhile

    cmd_buf ← lagl.SDL_AcquireGPUCommandBuffer device
    res texture width height ← lagl.SDL_WaitAndAcquireGPUSwapchainTexture cmd_buf window 0 0 0
    :If 0 = res
        ⎕ ← 'Error acquiring swapchain texture'
        ⎕SIGNAL 200
    :EndIf
    color_info ← ⊂(texture 0 0 (0.1 0.2 0.3 1) 1 0 0 0 0 0 0 0 0)
    pass ← lagl.SDL_BeginGPURenderPass cmd_buf color_info 1 0

    lagl.SDL_BindGPUGraphicsPipeline pass pipeline


    dt ← 500÷⍨⊃lagl.SDL_GetTicks⍬

    x_pos ← x_pos + x_dir × (0.004)
    y_pos ← y_pos + y_dir × (0.004)

    model_mat←4 4 ⍴ 1,4⍴0
    ⍝ Translation
    model_mat[;4] ← x_pos y_pos 0 1
    ⍝ Rotation
    model_mat[(1 1) (2 1) (1 2) (2 2)] ← (1 ¯1 1 1) × 2 1 1 2○dt dt dt dt
    ⍝ Row-major → Column major
    model_mat ← ⍉model_mat


    lagl.SDL_PushGPUVertexUniformData cmd_buf 0 (∊model_mat) (4×16)

    vbuffer_list ← ⊂(vertex_buffer 0)
    ibuffer_list ← ⊂(index_buffer 0)

    lagl.SDL_BindGPUVertexBuffers pass 0 vbuffer_list 1
    lagl.SDL_BindGPUIndexBuffer pass ibuffer_list lagl.SDL_GPU_INDEXELEMENTSIZE_16BIT
    lagl.SDL_DrawGPUIndexedPrimitives pass 6 1 0 0 0
    lagl.SDL_EndGPURenderPass pass
    lagl.SDL_SubmitGPUCommandBuffer cmd_buf

:EndWhile

lagl.SDL_ReleaseGPUShader device v_shader
lagl.SDL_ReleaseGPUShader device f_shader

lagl.SDL_ReleaseGPUGraphicsPipeline device pipeline

lagl.SDL_ReleaseGPUTransferBuffer device transfer_buffer
lagl.SDL_ReleaseGPUBuffer device index_buffer
lagl.SDL_ReleaseGPUBuffer device vertex_buffer

lagl.SDL_DestroyGPUDevice device
lagl.SDL_DestroyWindow window
lagl.SDL_Quit
