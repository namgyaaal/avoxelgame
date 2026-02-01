cbuffer MVPBlock : register(b0)
{
    row_major float4x4 _41_mvp : packoffset(c0);
};

uniform float4 gl_HalfPixel;

static float4 gl_Position;
static uint4 position;
static float3 out_uv;
static float z_depth;

struct SPIRV_Cross_Input
{
    float4 position : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float3 out_uv : TEXCOORD0;
    float z_depth : TEXCOORD1;
    float4 gl_Position : POSITION;
};

void vert_main()
{
    float4 pos = float4(float(position.x & 31u), float(position.y), float(position.z & 31u), 1.0f);
    gl_Position = mul(pos, _41_mvp);
    out_uv = float3(float(position.z >> uint(7)), float(position.x >> uint(7)), float(position.w));
    z_depth = gl_Position.z;
    gl_Position.x = gl_Position.x - gl_HalfPixel.x * gl_Position.w;
    gl_Position.y = gl_Position.y + gl_HalfPixel.y * gl_Position.w;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    position = stage_input.position;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.out_uv = out_uv;
    stage_output.z_depth = z_depth;
    return stage_output;
}
