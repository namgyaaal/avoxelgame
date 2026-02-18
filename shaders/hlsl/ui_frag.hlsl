uniform sampler2DArray sample_tex;

static float4 o_color;
static float3 uv;

struct SPIRV_Cross_Input
{
    float3 uv : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 o_color : COLOR0;
};

void frag_main()
{
    o_color = tex2D(sample_tex, uv);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    uv = stage_input.uv;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_color = float4(o_color);
    return stage_output;
}
