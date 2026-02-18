cbuffer MVPBlock : register(b0)
{
    row_major float4x4 _25_mvp : packoffset(c0);
};

uniform float4 gl_HalfPixel;

static float4 gl_Position;
static float3 o_uv;
static float3 uv;
static float2 position;

struct SPIRV_Cross_Input
{
    float2 position : TEXCOORD0;
    float3 uv : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float3 o_uv : TEXCOORD1;
    float4 gl_Position : POSITION;
};

void vert_main()
{
    o_uv = uv;
    gl_Position = mul(float4(position, -20.0f, 1.0f), _25_mvp);
    gl_Position.x = gl_Position.x - gl_HalfPixel.x * gl_Position.w;
    gl_Position.y = gl_Position.y + gl_HalfPixel.y * gl_Position.w;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    uv = stage_input.uv;
    position = stage_input.position;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.o_uv = o_uv;
    return stage_output;
}
