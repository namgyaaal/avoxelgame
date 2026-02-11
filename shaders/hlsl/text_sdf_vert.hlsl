cbuffer MVPBlock : register(b0)
{
    row_major float4x4 _30_mvp : packoffset(c0);
};

uniform float4 gl_HalfPixel;

static float4 gl_Position;
static float4 o_color;
static float4 color;
static float2 o_uv;
static float2 uv;
static float3 position;

struct SPIRV_Cross_Input
{
    float3 position : TEXCOORD0;
    float4 color : TEXCOORD1;
    float2 uv : TEXCOORD2;
};

struct SPIRV_Cross_Output
{
    float4 o_color : TEXCOORD0;
    float2 o_uv : TEXCOORD1;
    float4 gl_Position : POSITION;
};

void vert_main()
{
    o_color = color;
    o_uv = uv;
    gl_Position = mul(float4(position, 1.0f), _30_mvp);
    gl_Position.x = gl_Position.x - gl_HalfPixel.x * gl_Position.w;
    gl_Position.y = gl_Position.y + gl_HalfPixel.y * gl_Position.w;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    color = stage_input.color;
    uv = stage_input.uv;
    position = stage_input.position;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.o_color = o_color;
    stage_output.o_uv = o_uv;
    return stage_output;
}
