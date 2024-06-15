Shader "Unlit/SDFTest"
{
	Properties
	{
		_InsideColor("Inside Color", Color) = (0.1, 0.1, 0.1, 0.1)

		[Space][Space][Space][Space]

		_OutlineColor("Outline Color", Color) = (0.1, 0.1, 0.1, 0.1)
		_OutlineThickness("Outline Color", Range(0, 1)) = 1.0

		[Space][Space][Space][Space]

		[NoScaleOffset] _Icon("Icon", 2D) = "white" {}
		_IconSize("Icon Size", Float) = 1.0

		[Space][Space][Space][Space]

		_HighlightThickness("Highlight Thickness", Float) = 0.1
		_HighlightMoveSpeed("Highlight Move Speed", Float) = 1.0
		_HighlightColor("Highlight Color", Color) = (0.1, 0.1, 0.1, 1)

	}
	SubShader
	{
		Tags 
		{ 
			"RenderType"="Transparent" 
			"Queue"="Transparent"
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct mesh_data
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 scale : TEXCOORD1;
			};

			float _OutlineThickness;

			float4 _OutlineColor;
			float4 _InsideColor;

			float _HighlightThickness;
			float _HighlightMoveSpeed;
			float4 _HighlightColor;

			sampler2D _Icon;
			float _IconSize;

			v2f vert (mesh_data v)
			{
				v2f o;

				o.position = UnityObjectToClipPos( v.position );
				o.uv = v.uv;
				o.scale = float2( length( unity_ObjectToWorld._m00_m10_m20 ), length( unity_ObjectToWorld._m01_m11_m21 ) );

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{

				// OUTLINE
				float2 coords = i.uv * 2 - 1;
				coords.x = coords.x * i.scale.x;
				coords.y = coords.y * i.scale.y;

				float dY =  lerp(0, 1, (i.scale.y - _OutlineThickness - abs(coords.y)) < 0);
				float dX =  lerp(0, 1, (i.scale.x - _OutlineThickness - abs(coords.x)) < 0);

				int outlineMask = clamp(0, 1, dX + dY);

				// ICON 
				float2 iconCoords = coords;
				iconCoords = iconCoords + _IconSize / 2;
				iconCoords = iconCoords / _IconSize;

				float iconMask = tex2D(_Icon, iconCoords);
				
				// HIGHLIGHT
				float dispX = _Time.y * _HighlightMoveSpeed * i.scale.x % i.scale.x;
				float dispY = _Time.y * _HighlightMoveSpeed * i.scale.y % i.scale.y;

				float dhX = abs(coords.x) > dispX && abs(coords.x) < dispX + _HighlightThickness && abs(coords.y) < dispY + _HighlightThickness;
				float dhY = abs(coords.y) > dispY && abs(coords.y) < dispY + _HighlightThickness && abs(coords.x) < dispX + _HighlightThickness;

				int highlightMask = clamp(0, 1, dhX + dhY) * outlineMask;

				// FINAL COLOR

				float sdfMask = clamp(0, 1, outlineMask + iconMask);
				float4 baseColor = lerp(_InsideColor, _OutlineColor, sdfMask);
				
				float4 final = lerp(baseColor, _HighlightColor, highlightMask);
				return final;
			}

			ENDCG
		}
	}
}
