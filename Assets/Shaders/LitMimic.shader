Shader "Unlit/m_LitMimic"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 2)) = 0.01
		_Metallic("Metallic", Range(0, 2)) = 0.01
	}
	SubShader
	{
		Tags 
		{ 
			"RenderType" = "Opaque" 
		}

		// Base
		Pass
		{
			Name "FirstLight"
			Tags { "LightMode" = "UniversalForward" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "DM_Lighting.cginc"

			ENDCG
		}
	}
}
