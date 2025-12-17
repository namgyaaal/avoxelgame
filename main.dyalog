#!/usr/local/bin/dyalogscript
⎕SE.(⍎⊃2⎕FIX'/StartupSession.aplf',⍨2⎕NQ # 'GetEnvironment' 'DYALOG')
⎕SE.Link.Create 'lagl' './lagl'

lagl.sdl3.load_lib 'libs/libLSE.dylib'
lagl.lse.load_lib 'libs/libLSE.dylib'

:If 0 = lagl.SDL_Init lagl.SDL_INIT_VIDEO
    ⎕ ← 'Error initializing SDL3'
    ⎕SIGNAL 200
:Endif


⍝ Test surfaces real quick 

old_surface ← lagl.IMG_Load ⊂'assets/blocks.jpg'
surface ← lagl.SDL_ConvertSurface old_surface 376840196

width height pitch _ ← lagl.LSE_GetSurfaceParams surface 0 0 0 0
data_addr ← lagl.LSE_GetSurfaceDataAddress surface
data_size ← pitch × height
lagl.SDL_DestroySurface old_surface


⍝surface ← lagl.SDL_CreateSurface 128 128 lagl.SDL_PIXELFORMAT_RGBA128_FLOAT
⍝lagl.SDL_LockSurface surface
⍝data_addr ← lagl.LSE_GetSurfaceDataAddress surface
⍝data ← ∊(×/ 128 128 4)⍴ (255 0 0 255 255 0 0 255 0 0 255 255 0 0 255 255)
⍝data_size ← 4×≢data
⍝lagl.LSE_MemcpyF32 (data_addr) (data) data_size
⍝lagl.SDL_UnlockSurface surface
⍝lagl.SDL_DestroySurface surface

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


grass_uv ← (0.0 0.0) (0.2 0.0) (0.2 0.5) (0.0 0.5)
stone_uv ← (0.0 0.5) (0.2 0.5) (0.2 1.0) (0.0 1.0)
dirt_uv ← (0.4 0.0) (0.6 0.0) (0.6 0.5) (0.4 0.5)
wood_uv ← (0.8 0.0) (1.0 0.0) (1.0 0.5) (0.8 0.5)
uv_vec ← grass_uv stone_uv dirt_uv wood_uv

⍝(chunk_p indices) ← lagl.mk_chunk 5

⍝chunk_p ← chunk_p, 0
chunk_p ← lagl.chunk.vertices
indices ← lagl.chunk.indices
r ← ≢chunk_p 

color_p ← 1,⍨?0⍨¨chunk_p
uv_p ← r 2⍴∊6/uv_vec[?(r÷24)⍴≢uv_vec]

⍝⎕ ← chunk_p, color_p, uv_p
⍝⎕ ← indices

vertex_data ← ∊chunk_p, color_p, uv_p
vertex_size ← 4 × ≢vertex_data ⍝ in bytes for f32


index_data ← ∊indices 
index_size ← 2 × ≢index_data ⍝ bytes for u16

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

tex_tb_params ← ⊂lagl.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD (pitch × height) 0
tex_tb ← lagl.SDL_CreateGPUTransferBuffer device tex_tb_params

:If (0 = transfer_buffer) ∨ (0 = tex_tb)
    ⎕ ← 'Error creating transfer buffer'
    ⎕SIGNAL 200
:Endif

⍝ Create Sampler

⍝ SDL_GPUSamplerCreateInfo ← (i32 i32 i32 i32 i32 i32 f32 f32 i32 f32 f32 bool bool u8 u8 i32)
sampler_create_info ←⊂        0   0   0   2   2   2   0.0 0.0 0   0.0 0.0 0    0    0  0  0
sampler ← lagl.SDL_CreateGPUSampler device sampler_create_info

:If 0 = sampler
    ⎕ ← 'Error creating texture sampler'
    ⎕SIGNAL 200
:Endif

⍝ SDL_GPUTextureCreateInfo ← (i32 i32 i32 u32 u32 u32 u32 i32 i32)
texture_create_info ←⊂        0   lagl.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM   1   width height 1   1   0   0  
texture ← lagl.SDL_CreateGPUTexture device texture_create_info
lagl.SDL_SetGPUTextureName device texture 'test'

:If 0 = texture
    ⎕ ← 'Error creating texture'
    ⎕SIGNAL 200
:Endif


depth_texture_info ←⊂ 0 lagl.SDL_GPU_TEXTUREFORMAT_D16_UNORM 4 900 600 1 1 0 0
depth_texture ← lagl.SDL_CreateGPUTexture device depth_texture_info

:If 0 = depth_texture
    ⎕ ← 'Error creating dpeth texture'
    ⎕SIGNAL 200
:Endif


⍝ Copy vertex data into transfer buffer 
mem_ptr ← lagl.SDL_MapGPUTransferBuffer device transfer_buffer 0
lagl.LSE_MemcpyF32 (mem_ptr) (vertex_data) vertex_size
lagl.LSE_MemcpyU16 (mem_ptr + vertex_size) (index_data) index_size
lagl.SDL_UnmapGPUTransferBuffer device transfer_buffer

⍝ Copy texture into transfer buffer
mem_ptr ← lagl.SDL_MapGPUTransferBuffer device tex_tb 0
lagl.SDL_memcpy (mem_ptr) (data_addr) data_size
⍝lagl.LSE_MemcpyF32 (mem_ptr) (data_addr) (128 × 128 × 4 × 4)
lagl.SDL_UnmapGPUTransferBuffer device tex_tb

cmd_buf ← lagl.SDL_AcquireGPUCommandBuffer device
pass ← lagl.SDL_BeginGPUCopyPass cmd_buf
⍝ Vertex/Index data
lagl.SDL_UploadToGPUBuffer pass (transfer_buffer 0) (vertex_buffer 0 vertex_size) 0
lagl.SDL_UploadToGPUBuffer pass (transfer_buffer vertex_size) (index_buffer 0 index_size) 0
⍝ Texture data
lagl.SDL_UploadToGPUTexture pass (tex_tb 0 0 0) (texture 0 0 0 0 0 width height 1) 0

lagl.SDL_EndGPUCopyPass pass 
lagl.SDL_SubmitGPUCommandBuffer cmd_buf


⍝ Load shaders
v_src v_size ← lagl.SDL_LoadFile 'shaders/msl/basic_vert.msl' 0
f_src f_size ← lagl.SDL_LoadFile 'shaders/msl/basic_frag.msl' 0

:If (0 = v_src) ∨ (0 = f_src) 
    ⎕ ← 'Error loading shaders'
    ⎕SIGNAL 200
:Endif
v_info ← v_size v_src 0 lagl.SDL_GPU_SHADERFORMAT_MSL lagl.SDL_GPU_SHADERSTAGE_VERTEX 0 0 0 1 0
f_info ← f_size f_src 0 lagl.SDL_GPU_SHADERFORMAT_MSL lagl.SDL_GPU_SHADERSTAGE_FRAGMENT 1 0 0 0 0

v_shader ← lagl.LSE_CreateGPUShader device v_info 'main0'
f_shader ← lagl.LSE_CreateGPUShader device f_info 'main0'
:If (0 = v_src) ∨ (0 = f_src)
    ⎕ ← 'Error creating shaders'
    ⎕SIGNAL 200
:Endif


⍝ Create a render pipeline
lagl.LSE_PipelineClearParams⍬
lagl.LSE_PipelineSetShaders v_shader f_shader
⍝ Vertex Buffer Descriptions and Attributes : Vertex Input
vb_desc ←⊂ (0 (4 × 9) 0 0)
vb_attr ←⊂ (0 0 lagl.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3 0) 
vb_attr,←⊂ (1 0 lagl.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4 (4 × 3))
vb_attr,←⊂ (2 0 lagl.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2 (4 × 7))
lagl.LSE_PipelineSetVertexInput (⊂vb_desc), 1, (⊂vb_attr), 3
lagl.LSE_PipelineSetDepthStencil 2 (0 0 0 0) (0 0 0 0) 0 0 1 1 0 0 0 0
lagl.LSE_PipelineSetRasterizer 0 0 1 0.0 0.0 0.0 0 0

⍝ Color Targets
default_format ← ⊃lagl.SDL_GetGPUSwapchainTextureFormat device window


blend_state ← lagl.SDL_GPU_BLENDFACTOR_SRC_ALPHA
blend_state,← lagl.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA
blend_state,← lagl.SDL_GPU_BLENDOP_ADD
⍝ 0's - padding, writemask, etc
⍝ Duplicate alpha and color blendfactors and blendops
blend_state ← (5⍴0),⍨6⍴ blend_state
ct_desc ← ⊂default_format blend_state

lagl.LSE_PipelineSetTargetInfo (⊂ct_desc), 1 lagl.SDL_GPU_TEXTUREFORMAT_D16_UNORM 1
pipeline ← lagl.LSE_PipelineCreate device
:If 0 = pipeline
    ⎕ ← 'Error creating render pipeline'
    ⎕SIGNAL 200
:Endif

(x_dir y_dir) ← 0 0
proj_mat ← lagl.math.proj (75.0 × 180÷⍨○1) (900 ÷ 600) 0.1 100

view_mat ← lagl.math.look_at (4 4 8) (4 4 0) (0 1 0)
⍝view_mat ← lagl.math.look_at (2 6 ¯3) (2 4 0) (0 1 0)


raw ← 4 4⍴0.868817 0.000000 0.000000 0.000000 0.000000 1.303225 0.000000 0.000000 0.000000 0.000000 ¯1.001001 ¯1.000000 ¯3.475267 ¯5.212901 7.907908 8.000000
⎕ ← raw

c ← 0
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
    c ← c + 0.01

    x_pos ← 2×2○c
    y_pos ← 2×1○c
    ⍝z_pos ← 2×1○c

    ⍝view_mat ← lagl.math.look_at (x_pos y_pos z_pos) (0.0 0.0 0.0) (0.0 1.0 0.0)

    cmd_buf ← lagl.SDL_AcquireGPUCommandBuffer device
    res swap_texture width height ← lagl.SDL_WaitAndAcquireGPUSwapchainTexture cmd_buf window 0 0 0
    :If 0 = res
        ⎕ ← 'Error acquiring swapchain texture'
        ⎕SIGNAL 200
    :EndIf
    color_info ← ⊂(swap_texture 0 0 (0.1 0.2 0.3 1) 1 0 0 0 0 0 0 0 0)
    depth_info ← ⊂(depth_texture 0.00, 1 1 0 0 0 0 0 0)
    ⍝pass ← lagl.SDL_BeginGPURenderPass cmd_buf color_info 1 depth_info

    pass ← lagl.LSE_BeginGPURenderPass cmd_buf swap_texture depth_texture
    lagl.SDL_BindGPUGraphicsPipeline pass pipeline


    dt ← 500÷⍨⊃lagl.SDL_GetTicks⍬

    ⍝ use this later
    model_mat←4 4 ⍴ 1,4⍴0
    ⍝ Translation
    model_mat[;4] ← x_pos y_pos 0 1
    ⍝ Rotation
    model_mat[(1 1) (2 1) (1 2) (2 2)] ← (1 ¯1 1 1) × 2 1 1 2○dt dt dt dt
    ⍝ Row-major → Column major
    model_mat ← ⍉model_mat

    mvp ← view_mat +.× proj_mat


    lagl.LSE_PushTestMatrix cmd_buf dt
    ⍝lagl.SDL_PushGPUVertexUniformData cmd_buf 0 (∊raw) (16×4)

    vbuffer_list ← ⊂(vertex_buffer 0)
    ibuffer_list ← ⊂(index_buffer 0)

    lagl.SDL_BindGPUVertexBuffers pass 0 vbuffer_list 1
    lagl.SDL_BindGPUIndexBuffer pass ibuffer_list lagl.SDL_GPU_INDEXELEMENTSIZE_16BIT
    lagl.SDL_BindGPUFragmentSamplers pass 0 (⊂texture sampler) 1
    lagl.SDL_DrawGPUIndexedPrimitives pass (≢index_data) 1 0 0 0
    lagl.SDL_EndGPURenderPass pass
    lagl.SDL_SubmitGPUCommandBuffer cmd_buf

:EndWhile


lagl.SDL_ReleaseGPUShader device v_shader
lagl.SDL_ReleaseGPUShader device f_shader

lagl.SDL_ReleaseGPUGraphicsPipeline device pipeline

lagl.SDL_ReleaseGPUTransferBuffer device transfer_buffer
lagl.SDL_ReleaseGPUTransferBuffer device tex_tb
lagl.SDL_ReleaseGPUTexture device texture
lagl.SDL_ReleaseGPUSampler device sampler
lagl.SDL_ReleaseGPUBuffer device index_buffer
lagl.SDL_ReleaseGPUBuffer device vertex_buffer

lagl.SDL_DestroyGPUDevice device
lagl.SDL_DestroyWindow window
lagl.SDL_Quit⍬
