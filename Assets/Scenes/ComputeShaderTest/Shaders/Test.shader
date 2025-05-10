Shader "Custom/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Float) = 0.5
        _SpecularStrength("SpecularStrength", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward"}
            Cull Back

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3dll_9x
            #pragma target 2.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #define _SPECULAR_COLOR;

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Test.hlsl"

            ENDHLSL
        }

        Pass 
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile_shadowcaster

            #pragma vertex Vertex
            #pragma fragment Fragment

            #define SHADOW_CASTER_PASS

            #include "Test.hlsl"

            ENDHLSL
        }
    }
}
