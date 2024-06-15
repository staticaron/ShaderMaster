Shader "Unlit/GoldGun"
{
    Properties
    {
        [NoScaleOffset] _MainTex("Main Texture", 2D) = "white" {}
        [NoScaleOffset] _NormalMap("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _AOMap("Ambient Occlusion Map", 2D) = "white" {}
        [NoScaleOffset] _RoughnessMap("Roughness Map", 2D) = "black" {}

        [NoScaleOffset] _GoldMap("Gold Map", 2D) = "white" {}

        _Smoothness("Smoothness", Float) = 0.1
        _Ambient("Ambient", Float) = 0.1

        _GoldLineThickness("Gold Line Thickness", Float) = 0.1
        _GoldLineMoveSpeed("Gold Line Move Speed", Float) = 1
        [HDR]_GoldLineColor("Gold Line Color", Color) = (0.1, 0.8, 0.1, 1)
        _Delay("Repeat Delay", Float) = 2.0
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
            #include "Lighting.cginc"

            struct mesh_data
            {
                float4 position : POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
                float3 wPos : TEXCOORD5;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _AOMap;
            sampler2D _RoughnessMap;
            sampler2D _GoldMap;

            float _Smoothness;
            float _Ambient;

            float  _GoldLineThickness;
            float  _GoldLineMoveSpeed;
            float4 _GoldLineColor;
            float _Delay;

            float inverse_lerp(float x, float y, float v, bool isLeft)
            {
                float i = (v - x) / (y - x);
                i = lerp(1 - i, i, isLeft);
                return lerp(i , 0, i < 0 || i > 1);
            }

            v2f vert (mesh_data v)
            {
                v2f o;

                o.position = UnityObjectToClipPos(v.position);

                o.uv1 = v.uv1;
                o.uv2 = v.uv2;

                o.normal = v.normal;
                o.tangent = UnityObjectToWorldDir( v.tangent.xyz );
                o.bitangent = cross( o.normal, o.tangent ) * ( v.tangent.w * unity_WorldTransformParams.w );

                o.wPos = mul(unity_ObjectToWorld, v.position);

                return o;
            }

            float4 get_lighting(float3 N, float3 L, float3 V, float3 color, float smoothness)
            {
                float lambert = saturate ( dot(N, L) );
                float3 H = normalize(L + V);

                float3 diffuse = (lambert + _Ambient) * color;
                float specular = saturate ( dot(N, H) ) * ( lambert > 0 );

                return float4(diffuse, pow(specular, ( smoothness ) * 100));
            }

            float get_gold(float2 iv)
            {
                float moveline = 1 - (_Time.y * _GoldLineMoveSpeed % _Delay);

                if(moveline > 1) return 0;
                
                float goldLeft  = inverse_lerp(moveline - _GoldLineThickness, moveline, iv, true);
                float goldRight = inverse_lerp(moveline, moveline + _GoldLineThickness, iv, false);
                float gold      = lerp(goldRight, goldLeft, iv < moveline);

                return clamp ( gold * saturate( tex2D( _GoldMap, iv ).x ) , 0 , 1);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalMapSample = UnpackNormal( tex2D( _NormalMap, i.uv1) );

                float3x3 mtxTangentToWorld = 
                {
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                };

                float3 N = mul( mtxTangentToWorld, normalMapSample );
                float3 V = normalize( _WorldSpaceCameraPos.xyz - i.wPos );

                float4 lightOutput = get_lighting(UnityObjectToWorldNormal( N ), _WorldSpaceLightPos0.xyz, V, _LightColor0, _Smoothness);

                float3 mainTexSample = tex2D(_MainTex, i.uv1);
                float  aoSample      = tex2D(_AOMap, i.uv1).x;
                float  goldSample    = get_gold(i.uv2);


                float4 finalRGB = float4( ( lightOutput.xyz * mainTexSample + lightOutput.www * tex2D(_RoughnessMap, i.uv1).x + _GoldLineColor * goldSample), 1);

                return finalRGB * aoSample;
            }

            ENDCG
        }
    }
}
