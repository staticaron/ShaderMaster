#ifndef GOLDGUN_BETTER_INCLUDED
#define GOLDGUN_BETTER_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "NMGGeometryHelpers.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
    float3 uv2 : TEXCOORD1;
};

struct VertexOutput
{
	float4 positionCS : SV_POSITION;
	
	float3 positionWS : TEXCOORD0;
	float3 normalWS : TEXCOORD1;
	float2 uv : TEXCOORD2;
    float2 uv2 : TEXCOORD3;
    float4 tangentWS : TEXCOORD4;
};

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_ST;
TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap); float _NormalStrength;
TEXTURE2D(_GoldMap); SAMPLER(sampler_GoldMap); 
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap); float _EmissionStrength;

float _Metallic, _Smoothness, _SpecularStrength;

VertexOutput Vertex(Attributes input)
{
	VertexOutput output = (VertexOutput) 0;
	
	VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
	output.positionWS = positionInputs.positionWS;
	output.positionCS = positionInputs.positionCS;
	
	VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
	output.normalWS = normalInputs.normalWS;
    output.tangentWS = float4(normalInputs.tangentWS, input.tangentOS.w);
	
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.uv2 = TRANSFORM_TEX(input.uv2, _MainTex);
	
	return output;
}

float4 Fragment(VertexOutput input) : SV_Target
{
#ifdef SHADOW_CASTER_PASS
	return 0;
#else	
    float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv), _NormalStrength);
    float3x3 tangentToWorld = CreateTangentToWorld(input.normalWS, input.tangentWS.xyz, input.tangentWS.w);
    float3 normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
	
    InputData lightingInput = (InputData) 0;
    lightingInput.positionWS = input.positionWS;
    lightingInput.normalWS = normalWS;
    lightingInput.viewDirectionWS = GetViewDirectionFromPosition(input.positionWS);
    lightingInput.shadowCoord = CalculateShadowCoord(input.positionWS, input.positionCS);
	
    
    float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).rgb;
    float goldMapValue = SAMPLE_TEXTURE2D(_GoldMap, sampler_GoldMap, input.uv2).r;
	
    SurfaceData surfaceData = (SurfaceData) 0;
    surfaceData.albedo = albedo;
    surfaceData.metallic = _Metallic * goldMapValue;
    surfaceData.specular = 1 * _SpecularStrength;
    surfaceData.smoothness = _Smoothness;
    surfaceData.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv) * _EmissionStrength;
    surfaceData.alpha = 1;
	
    return UniversalFragmentPBR(lightingInput, surfaceData);
#endif
}

#endif