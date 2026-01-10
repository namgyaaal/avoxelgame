uniform sampler2D sampleTex;

static float4 out_color;
static float2 in_uv;

struct SPIRV_Cross_Input
{
    float2 in_uv : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 out_color : COLOR0;
};

void frag_main()
{
    out_color = tex2D(sampleTex, in_uv);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    in_uv = stage_input.in_uv;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.out_color = float4(out_color);
    return stage_output;
}
