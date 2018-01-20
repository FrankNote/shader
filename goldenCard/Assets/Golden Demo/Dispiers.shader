Shader "Custom/Dispiers" {
	Properties {
		_Diffuse ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_ColorA ("ColorA", Color) = (1,1,1,1)
		_ColorB ("ColorB", Color) = (1,1,1,1)
		_AThreshold ("_AThreshold", Range(0,1)) = 0.6
		_BThreshold ("_BThreshold", Range(0,1)) = 0.8
		_NoiseThreshold ("NoiseThreshold", Range(0,1)) = 0.0
		_flyValue ("_flyValue", Range(0,1)) = 0.8
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		sampler2D _MainTex;
		half4 _MainTex_ST;
		sampler2D _NoiseTex;
		half4 _NoiseTex_ST;
		half _NoiseThreshold;
		fixed4 _Diffuse;
		fixed4 _ColorA;
		fixed4 _ColorB;
		half _AThreshold;
		half _BThreshold;
		half _flyValue;
		struct v2f{
			half4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half3 worldNormal:TEXCOORD1;
			half3 worldLight:TEXCOORD2;
		};
		v2f vert(appdata_base v)
		{
			v2f o;
			v.vertex.xyz += v.normal * _NoiseThreshold *saturate(_NoiseThreshold - _flyValue); 
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldLight = UnityObjectToWorldDir(_WorldSpaceLightPos0.xyz);

			return o;
		}
		fixed4 frag(v2f i):SV_Target
		{
			fixed4 noiseColor = tex2D(_NoiseTex,i.uv);
			if (noiseColor.b < _NoiseThreshold )
				discard;

			if (_NoiseThreshold/noiseColor.r > _AThreshold)
			{
				 if (_NoiseThreshold/noiseColor.r > _BThreshold)
				 {
				 	return _ColorB;
				 }
				 return _ColorA;
			}
			fixed3 nor = normalize(i.worldNormal);
			fixed3 light = normalize(i.worldLight);
			fixed3 diffuses = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(nor,light)) + UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed4 c = tex2D(_MainTex,i.uv);
			return fixed4(c.rgb*diffuses,1);
		}
		ENDCG
		Pass{
			Tags{"RenderType" = "Opaque"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

	}
	FallBack "Diffuse"
}
