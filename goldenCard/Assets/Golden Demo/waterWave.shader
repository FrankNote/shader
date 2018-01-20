Shader "Custom/waterWave" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}

	}
		CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		uniform float _distanceFactor;
		uniform float _timeFactor;
		uniform float _totalFactor;

		fixed4 frag(v2f_img i):SV_Target
		{
			half2 distance = half2(0.5,0.5) - i.uv;
			half length = sqrt(distance.x * distance.x + distance.y *distance.y);
			half sinFactor = sin(length * _distanceFactor + _Time.y * _timeFactor) * _totalFactor * 0.01;
			half2 dir = normalize(distance);
			half offset = sinFactor * dir;
			fixed4 color = tex2D(_MainTex,i.uv + offset);
			return color;
		}
		ENDCG
	SubShader {
		


		Pass
		{
			Tags { "RenderType"="Opaque" }
			LOD 200
			ZWrite off
			ZTest Always
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}


	}
	FallBack "Diffuse"
}
