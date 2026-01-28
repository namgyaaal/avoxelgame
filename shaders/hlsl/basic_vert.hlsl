cbuffer MVPBlock : register(b0)
{
    row_major float4x4 _19_mvp : packoffset(c0);
};

cbuffer ViewBlock : register(b1)
{
    row_major float4x4 _45_model : packoffset(c0);
};

uniform float4 gl_HalfPixel;

static float4 gl_Position;
static float3 position;
static float2 out_uv;
static float2 uv;
static float z_depth;

struct SPIRV_Cross_Input
{
    float3 position : TEXCOORD0;
    float2 uv : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float2 out_uv : TEXCOORD0;
    float z_depth : TEXCOORD1;
    float4 gl_Position : POSITION;
};

void vert_main()
{
    gl_Position = mul(float4(position, 1.0f), _19_mvp);
    out_uv = uv;
    float4 pos = mul(float4(position, 1.0f), _45_model);
    z_depth = gl_Position.z;
    gl_Position.x = gl_Position.x - gl_HalfPixel.x * gl_Position.w;
    gl_Position.y = gl_Position.y + gl_HalfPixel.y * gl_Position.w;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    position = stage_input.position;
    uv = stage_input.uv;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.out_uv = out_uv;
    stage_output.z_depth = z_depth;
    return stage_output;
}
