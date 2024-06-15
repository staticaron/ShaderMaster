Shader "Unlit/m_Grass"
{
    Properties
    {
        _Noise("Perlin Noise", 2D) = "white" {}
        _WindSpeed("Wind Speed", Float) = 1.0

        _MaxDisplacement("Max Displacement", Float) = 1.0


        _TopTint("Top Tint", Color) = (1, 1, 1, 1)
        _BottomTint("Bottom Tint", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            Cull Off

            CGPROGRAM

            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            
            #include "UnityCG.cginc"
            #pragma multi_compile_instancing

            #define PI 3.1415

            float _MaxDisplacement;

            float4 _TopTint;
            float4 _BottomTint;

            sampler2D _Noise;
            float _WindSpeed;

            struct MeshData
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float looper(float2 coordinates)
            {
                coordinates.x -= floor(coordinates.x);
                coordinates.y -= floor(coordinates.y);

                float4 value = tex2Dlod(_Noise, float4(coordinates, 0, 1));

                return value.x;
            }

            v2f vertex_shader (MeshData v)
            {
                v2f o;
                v.uv.x = 1 - v.uv.x;

                float3 worldPos = mul(unity_ObjectToWorld, v.position);

                float lerper = 1 - cos(PI * 0.5 * v.uv.x);

                float lookupCoords = float2(floor(worldPos.x), floor(worldPos.y));

                float displacement = lerp(0, looper(lookupCoords) * _MaxDisplacement, lerper);

                float3 worldVert = mul((float3x3) unity_ObjectToWorld, v.position.xyz);
                worldVert += float4(0, 0, displacement, 0); 

                v.position = mul(unity_WorldToObject, worldVert);

                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                o.worldPos = worldPos;

                return o;
            }

            fixed4 fragment_shader (v2f i) : SV_Target
            {
                return floor(i.worldPos.x);
                return lerp(_BottomTint, _TopTint, i.uv.x);
            }

            ENDCG
        }
    }
}
