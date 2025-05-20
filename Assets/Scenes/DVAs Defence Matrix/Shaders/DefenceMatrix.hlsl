#ifndef DEFENCEMATRIX_INCLUDED
#define DEFENCEMATRIX_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct AppData
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
};

struct VertexOutput
{
    float4 positionCS : SV_POSITION;
    float3 normalWS : TEXCOORD0;
    float2 uv : TEXCOORD1;
};

float4 _Tint;

VertexOutput Vertex(AppData input)
{
    VertexOutput vo = (VertexOutput) 0;
    
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    vo.positionCS = positionInputs.positionCS;
    
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
    vo.normalWS = normalInputs.normalWS;
    
    vo.uv = input.uv;
    
    return vo;
}

float4 Fragment(VertexOutput input) : SV_Target
{
    return float4(input.uv, 0.0, 0.5);
}

#endif