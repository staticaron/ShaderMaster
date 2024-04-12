Shader "Unlit/SoundBarrier"
{
    Properties
    {
        _DistanceValue("Distance Value", Range(0, 1)) = 0.5
        _MaxDistance("Max Wave Distance", Float) = 10

        _WaveCount("Wave Count", Float) = 10
        _WaveAmp("Wave Amplitude", Float) = 0.4

        _WaveWobbleSpeed("Wave Wobble Speed", Float) = 1
        _DisplacementFromLine("Displacement From Line", Float) = 0.1

        _WaveTint("Wave Tint", Color) = (1, 1, 1, 1)
        _BorderTint("Border Tint", Color) = (1, 1, 1, 1)

        _BorderThickness("Border Thickness", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        Pass
        {
            ZWrite Off
            Blend One One
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #define TAU 6.28318

            float _DistanceValue;
            float _MaxDistance;

            float _WaveCount;
            float _WaveAmp;

            float _WaveWobbleSpeed;
            float _DisplacementFromLine;

            float4 _WaveTint;   
            float4 _BorderTint;

            float _BorderThickness;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float distance : TEXCOORD2;
                float4 localVertex : TEXCOORD3;
            };

            v2f vert (MeshData v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localVertex = v.vertex;
                o.uv = v.uv;
                o.normal = v.normal;
                
                o.distance = length( mul((float3x3) unity_ObjectToWorld, v.vertex.xyz) );

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float avoidTopBottom = abs(i.normal.y) < 0.9999;

                float2 coords = i.uv;
                coords.x *= 8;
                coords.y -= 0.5;

                float waveMover = _Time.y * _WaveWobbleSpeed;

                float amplitude = lerp(_WaveAmp, 0, _DistanceValue);

                float restrictor = coords.y > 0;
                
                float wobbledCoordsX = coords.x + waveMover;
                float wobbledCoordsY = coords.x - waveMover;
                
                float wave1 = (coords.y - _DisplacementFromLine) < cos(wobbledCoordsX * _WaveCount * TAU) * amplitude && restrictor;
                float wave2 = coords.y + _DisplacementFromLine > cos(wobbledCoordsY * _WaveCount * TAU) * amplitude && 1 - restrictor;

                float borderMaskUpper = saturate(( coords.y - _DisplacementFromLine ) < cos( wobbledCoordsX * _WaveCount * TAU ) * amplitude && (coords.y - _DisplacementFromLine) > (cos(wobbledCoordsX * _WaveCount * TAU) * amplitude - _BorderThickness) && coords.y > 0);
                float borderMaskLower = saturate(( coords.y + _DisplacementFromLine ) > cos( wobbledCoordsY * _WaveCount * TAU ) * amplitude && (coords.y + _DisplacementFromLine) < (cos(wobbledCoordsY * _WaveCount * TAU) * amplitude + _BorderThickness) && coords.y < 0);

                float borderMask = borderMaskUpper + borderMaskLower;

                float4 clr = lerp(_WaveTint * _WaveTint.a, _BorderTint, borderMask);

                float4 finalColor = clr * avoidTopBottom * saturate(wave1+wave2) * saturate((1 - _DistanceValue));

                return finalColor; 
            }

            ENDCG
        }
    }
}
