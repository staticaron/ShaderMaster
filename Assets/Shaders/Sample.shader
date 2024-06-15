Shader "Unlit/Sample"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct mesh_data
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;

            v2f vert (mesh_data v)
            {
                v2f o;

                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv = i.uv * 2 - 1;

                return tex2D(_MainTex, i.uv) + float4(i.uv, 0, 1) * 0.5;
            }
            ENDCG
        }
    }
}
