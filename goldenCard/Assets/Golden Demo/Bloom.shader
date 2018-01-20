Shader "Custom/Bloom" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BlurTex("Blur",2D) = "white"{}
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		struct v2f_threshold
		{
			half4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
		};
		struct v2f_blur
		{
			half4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half4 uv12:TEXCOORD1;
			half4 uv34:TEXCOORD2;
			half4 uv56:TEXCOORD3;
		};
		struct v2f_bloom
		{
			half4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half2 uv1:TEXCOORD1;

		};
		sampler2D _MainTex;
		half4 _MainTex_ST;
		half4 _MainTex_TexelSize;
		sampler2D _BlurTex;
		half4 _BlurTex_TexelSize;
		half4 _BlurTex_ST;
		half4 _offsets;
		fixed4 _colorThreshold;
		fixed4 _bloomColor;
		half _bloomFactor;
		v2f_threshold vert_threshold(appdata_img v)
		{
			v2f_threshold o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
			//o.uv = v.texcoord.xy;
			#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
					o.uv.y = 1 - o.uv.y;
			#endif
			return o;
		}
		fixed4 frag_threshold(v2f_threshold i):SV_Target
		{
			fixed4 c = tex2D(_MainTex,i.uv);
			return saturate(c - _colorThreshold);
		}
		v2f_blur vert_blur(appdata_img v)
		{
			v2f_blur o;
			_offsets *= _MainTex_TexelSize.xyxy;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.uv = v.texcoord.xy;
			o.uv12 = v.texcoord.xyxy + _offsets.xyxy * float4(1,1,-1,-1);
			o.uv34 = v.texcoord.xyxy + _offsets.xyxy * float4(2,2,-2,-2);
			o.uv56 = v.texcoord.xyxy + _offsets.xyxy * float4(3,3,-3,-3);
			return o;
		}
		fixed4 frag_blur(v2f_blur i):SV_Target
		{
			fixed4 c = fixed4(0,0,0,0);
			c += 0.4 * tex2D(_MainTex,i.uv);
			c += 0.15 * tex2D(_MainTex,i.uv12.xy);
			c += 0.15 * tex2D(_MainTex,i.uv12.zw);
			c += 0.1 * tex2D(_MainTex,i.uv34.xy);
			c += 0.1 * tex2D(_MainTex,i.uv34.zw);
			c += 0.05 * tex2D(_MainTex,i.uv56.xy);
			c += 0.05 * tex2D(_MainTex,i.uv56.zw);
			return c;
		}
		v2f_bloom vert_bloom(appdata_img v)
		{
			v2f_bloom o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
			//o.uv = v.texcoord.xy;
			o.uv1.xy = o.uv.xy;
			#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
					o.uv.y = 1 - o.uv.y;
			#endif
			return o;
		}
		fixed4 frag_bloom(v2f_bloom i):SV_Target
		{
			fixed4 ori = tex2D(_MainTex,i.uv1);
			fixed4 blur = tex2D(_BlurTex,i.uv);
			fixed4 c = ori + blur * _bloomFactor * _bloomColor;
			return c;
		}
	ENDCG
	SubShader {
		Pass
		{
			ZTest off
			Cull off
			ZWrite off
			//Fog[Mode off]
			CGPROGRAM
			#pragma vertex vert_threshold
			#pragma fragment frag_threshold
			ENDCG
		}
		Pass
		{
			ZTest off
			Cull off
			ZWrite off
			//Fog[Mode off]
			CGPROGRAM
			#pragma vertex vert_blur
			#pragma fragment frag_blur
			ENDCG
		}
		Pass
		{
			ZTest off
			Cull off
			ZWrite off
			Fog{Mode off}
			CGPROGRAM
			#pragma vertex vert_bloom
			#pragma fragment frag_bloom
			ENDCG
		}
	}
	FallBack "Diffuse"
}
