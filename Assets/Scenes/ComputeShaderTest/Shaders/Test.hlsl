#ifndef PYRAMIDFACES_INCLUDED
#define PYRAMIDFACES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "NMGGeometryHelpers.hlsl"

struct Attributes
{
	float4 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float3 tangentOS : TANGENT;
	float2 uv : TEXCOORD0;
};

struct VertexOutput
{
	float3 positionWS : TEXCOORD0;
	float2 uv : TEXCOORD1;
	float3 normalWS : TEXCOORD2;
	
	float4 positionCS : SV_POSITION;
};

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_ST;
float _Smoothness, _SpecularStrength;

VertexOutput Vertex(Attributes input)
{
	VertexOutput output = (VertexOutput)0;
	
	VertexPositionInputs vertexInputs = GetVertexPositionInputs(input.positionOS.xyz);
	output.positionCS = vertexInputs.positionCS;
	output.positionWS = vertexInputs.positionWS;
	
	VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
	output.normalWS = normalInputs.normalWS;
	
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
	
	return output;
}

float4 Fragment(VertexOutput input) : SV_Target
{
#ifdef SHADOW_CASTER_PASS
	return 0;
#else
	
	InputData lightingInput = (InputData) 0;
    lightingInput.positionWS = input.positionWS;
    lightingInput.normalWS = input.normalWS;
    lightingInput.viewDirectionWS = GetViewDirectionFromPosition(input.positionWS);
    lightingInput.shadowCoord = CalculateShadowCoord(input.positionWS, input.positionCS);
	
	float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).rgb;
	
    SurfaceData surfaceData = (SurfaceData) 0;
    surfaceData.albedo = albedo;
    surfaceData.specular = 1 * _SpecularStrength;
    surfaceData.smoothness = _Smoothness;
    surfaceData.emission = 0;
    surfaceData.alpha = 1;
	
	// The arguments are lightingInput, albedo color, specular color, smoothness, emission color, and alpha
    return UniversalFragmentBlinnPhong(lightingInput, surfaceData);
	
#endif
}
#endif