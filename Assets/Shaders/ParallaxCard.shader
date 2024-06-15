Shader "Unlit/ParallaxCard"
{
    Properties
    {
        _Albedo("Albedo", Color) = (1, 1, 1, 1)
        _Smoothness("Gloss", Range(0, 1)) = 0.1
        _Metallic("Metallic", Range(0, 1)) = 0.1

        _Magnifier("Magnifier", Range(0, 1)) = 0.2

        _Values("Values", Vector) = (0, 0, 0, 0)

        _BG("BG", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertexprogram
            #pragma fragment fragprogram
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct mesh_data
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4 _Albedo;
            float _Smoothness, _Metallic;
            float _Magnifier;

            float4 _Values;

            sampler2D _BG;

            v2f vertexprogram (mesh_data v)
            {
                v2f o;

                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.position);

                return o;
            }

            fixed4 fragprogram (v2f i) : SV_Target
            {
                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz;

                float diffuse = saturate(dot(N, L));
                
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 H = normalize(L + V);

                float specular = saturate(dot(H, N)) * (diffuse > 0);

                float specularExp = exp2(_Smoothness * 11 + 1);
                specular = pow(specular, specularExp);

                float2 coords = i.uv;
                coords *= ( 1 - _Magnifier );
                coords += _Magnifier / 2;

                float3 objectView = normalize( _WorldSpaceCameraPos - unity_ObjectToWorld._m03_m13_m23 );
                objectView.z *= -1; // fuck quads

                coords.x += objectView.x * _Values.z;
                coords.y += objectView.y * _Values.z;

                float3 rgb = tex2D(_BG, coords);
                return float4(saturate(rgb * diffuse + specular * _Metallic), 1);
            }

            ENDCG
        }
    }
}
