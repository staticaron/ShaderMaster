Shader "Custom/NormalTesting"
{
    Properties
    {
        [NoScaleOffset] _HeightMap("Height Map", 2D) = "grey" {}   
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _HeightMap;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_HeightMap, IN.uv_MainTex);
        }
        ENDCG
    }

    FallBack "Diffuse"
}
