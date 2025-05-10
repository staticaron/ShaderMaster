Shader "Custom/GoldGun_Better"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [NoScaleOffset][Normal] _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0, 1)) = 1

        [NoScaleOffset] _GoldMap ("Gold Map", 2D) = "white" {}

        [NoScaleOffset] _EmissionMap ("Emission Map", 2D) = "white" {}
        _EmissionStrength("Emission Strength", Float) = 1

        _Metallic ("Metallic", Range(0, 1)) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _SpecularStrength("Specular Strength", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipelien"="UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode"="UniversalForward"}
            Cull Back

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma target 2.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "GoldGun_Better.hlsl"

            ENDHLSL
        }

        Pass 
        {
            Name "ShadowCaster"
            Tags {"LightMode"="ShadowCaster"}

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile_shadowcaster

            #pragma vertex Vertex
            #pragma fragment Fragment

            #define SHADOW_CASTER_PASS

            #include "GoldGun_Better.hlsl"

            ENDHLSL
        }
    }
}
