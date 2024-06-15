Shader "Unlit/Foliage"
{
    Properties
    {
        _Scale("Scale", Float) = 1.0
        _Weight("Weight", Range(0, 1)) = 1.0

        _BaseColor("BaseColor", Color) = (1.0, 1.0, 1.0, 1.0)
        _EdgeColor("EdgeColor", Color) = (1.0, 1.0, 1.0, 1.0)

        _Ambient("Ambient", Range(0, 1)) = 0.1

        [NoScaleOffset] _AlphaCard("Alpha Card", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct mesh_data
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float normal : NORMAL;
            };
            
            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float normal : TEXCOORD1;
            };

            float _Scale;
            float _Weight;

            float4 _BaseColor;
            float4 _EdgeColor;

            float _Ambient;

            sampler2D _AlphaCard;

            v2f vert (mesh_data v)
            {
                v2f o;

                float3 uvs = float3(v.uv * _Scale - _Scale * 0.5, 0) * _Weight;

                uvs = mul(uvs, UNITY_MATRIX_V);

                float4 wPos = mul(v.position, unity_ObjectToWorld);
                wPos.xyz += uvs;

                wPos = mul(wPos, unity_ObjectToWorld);  

                o.position = UnityObjectToClipPos(wPos);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float diffuseLighting(float3 normal, float3 L)
            {
                return dot(normal, L);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float alpha = tex2D(_AlphaCard, i.uv).x;

                clip(alpha - 0.5);

                float3 L = _WorldSpaceLightPos0;

                float diffuse = diffuseLighting(i.normal, L);

                float4 rgb = lerp(_BaseColor, _EdgeColor, i.position);

                return lerp(_Ambient, 1, saturate(diffuse));

                float diffuse_ambienance = lerp(0, diffuse, diffuse);

                return diffuse_ambienance * rgb;
            }

            ENDCG
        }
    }
}
