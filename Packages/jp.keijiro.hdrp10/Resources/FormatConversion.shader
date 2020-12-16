Shader "Hidden/Hdrp10/FormatConversion"
{
    HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

    static const float3x3 Rec709ToRec2020 =
    {
        0.627402, 0.329292, 0.043306,
        0.069095, 0.919544, 0.011360,
        0.016394, 0.088028, 0.895578
    };

    float3 LinearToST2084(float3 color)
    {
        float m1 = 2610.0 / 4096.0 / 4;
        float m2 = 2523.0 / 4096.0 * 128;
        float c1 = 3424.0 / 4096.0;
        float c2 = 2413.0 / 4096.0 * 32;
        float c3 = 2392.0 / 4096.0 * 32;
        float3 cp = pow(abs(color), m1);
        return pow((c1 + c2 * cp) / (1 + c3 * cp), m2);
    }

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vertex(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }

    TEXTURE2D_X(_InputTexture);
    float _PaperWhite;

    float4 SampleInput(int2 coord)
    {
        coord = min(max(0, coord), _ScreenSize.xy - 1);
        return LOAD_TEXTURE2D_X(_InputTexture, coord);
    }

    float4 Fragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        int2 positionSS = input.texcoord * _ScreenSize.xy;
        float4 c = SampleInput(positionSS);

        const float st2084max = 10000.0;
        const float hdrScalar = _PaperWhite / st2084max;
        c.rgb = mul(Rec709ToRec2020, c.rgb);
        c.rgb = LinearToST2084(c.rgb * hdrScalar);

        return c;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Cull Off ZWrite Off ZTest Always
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDHLSL
        }
    }
    Fallback Off
}
