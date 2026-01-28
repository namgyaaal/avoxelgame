uniform sampler2D sampleTex;

static float in_z_depth;
static float4 out_color;
static float2 in_uv;

struct SPIRV_Cross_Input
{
    float2 in_uv : TEXCOORD0;
    float in_z_depth : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 out_color : COLOR0;
};

static float fog_start;
static float fog_end;
static float4 fog_color;

void frag_main()
{
    fog_start = 30.0f;
    fog_end = 50.0f;
    fog_color = float4(0.4699999988079071044921875f, 0.4799999892711639404296875f, 0.4900000095367431640625f, 1.0f);
    float fog_factor = (fog_end - in_z_depth) / (fog_end - fog_start);
    fog_factor = clamp(fog_factor, 0.0f, 1.0f);
    out_color = lerp(fog_color, tex2D(sampleTex, in_uv), fog_factor.xxxx);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    in_z_depth = stage_input.in_z_depth;
    in_uv = stage_input.in_uv;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.out_color = float4(out_color);
    return stage_output;
}
