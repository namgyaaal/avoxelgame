static float4 out_color;
static float4 in_color;

struct SPIRV_Cross_Input
{
    float4 in_color : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 out_color : COLOR0;
};

void frag_main()
{
    out_color = in_color;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    in_color = stage_input.in_color;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.out_color = float4(out_color);
    return stage_output;
}
