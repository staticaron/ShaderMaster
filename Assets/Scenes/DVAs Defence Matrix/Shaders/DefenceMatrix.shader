Shader "Custom/DefenceMatrix"
{
    Properties
    {
        _Tint("Tint", Color) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "Queue"="Transparent"}
        LOD 100

        Pass
        {
            Name "Forward"
            Tags {"LightMode"="UniversalForward" }
            Cull Off
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

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

            #include "DefenceMatrix.hlsl"

            ENDHLSL
        }
    }
}
