uniform sampler2D sample_tex;

static float4 o_color;
static float4 color;
static float2 uv;

struct SPIRV_Cross_Input
{
    float4 color : TEXCOORD0;
    float2 uv : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 o_color : COLOR0;
};

void frag_main()
{
    o_color = color * tex2D(sample_tex, uv);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    color = stage_input.color;
    uv = stage_input.uv;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_color = float4(o_color);
    return stage_output;
}
