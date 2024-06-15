#include "UnityStandardBRDF.cginc"

struct mesh_data
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};

struct interpolator
{
	float4 position : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
};

sampler2D _MainTex;
float _Smoothness, _Metallic;

interpolator vert (mesh_data v)
{
	interpolator o;

	o.position = UnityObjectToClipPos( v.position );
	o.uv = v.uv;
	o.normal = UnityObjectToWorldNormal( v.normal );
	o.worldPos = mul( unity_ObjectToWorld, v.position );

	return o;
}

float4 frag ( interpolator i ) : SV_Target
{
	float3 N = normalize( i.normal );
	float3 L = _WorldSpaceLightPos0.xyz;
	float3 lambert = saturate( dot( N, L ) );
	float3 diffused = lambert * _LightColor0;

	float3 V = normalize( _WorldSpaceCameraPos.xyz - i.worldPos );
	float3 H = normalize( L + V );
				
	float3 specular = pow( saturate( dot( H, N ) ) * ( lambert > 0 ), _Smoothness * 100 );

	return float4(diffused + specular, 1);
}