Shader "Custom/ScanEffect" {
	Properties {
		_ScanColor ("Color", Color) = (1,0,0,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_ScanDistance ("ScandDis", float) = 0
		_ScanWidth ("ScanWidth", float) = 5.0
	}
	SubShader {
		CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		half4 _MainTex_ST;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float _ScanDistance;
		float _ScanWidth;
		fixed4 _ScanColor;
		struct v2f{
			half4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half2 uv1:TEXCOORD1;
		};
		v2f vert(appdata_base v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
			o.uv1 = o.uv;
			#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
					o.uv1.y = 1 - o.uv1.y;
			#endif
			return o;
		}
		fixed4 frag(v2f i):SV_Target
		{
			half4 col = tex2D(_MainTex,i.uv);
			half depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv1);
			half line01Depth = Linear01Depth(depth);
			if(line01Depth < _ScanDistance && line01Depth < 1 && line01Depth > _ScanDistance - _ScanWidth)
			{
				half diff = 1 - (_ScanDistance - line01Depth)/_ScanWidth;
				_ScanColor *= diff;
				return _ScanColor + col;
			}
			return col;
		}

		ENDCG
		Pass{
			Tags { "RenderType"="Opaque" }
			LOD 200
			ZWrite off
			CGPROGRAM
			// Use shader model 3.0 target, to get nicer looking lighting

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

	}
	FallBack "Diffuse"
}
