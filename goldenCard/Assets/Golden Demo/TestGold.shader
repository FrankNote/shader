Shader "Custom/TestGold" {
	Properties {
		_MainTex("Texture", 2D) = "black" {}
		_DistTex("Distortion Texture",2D) = "grey"{}
		_DistMask("Distortion Mask",2D)  = "black"{}

		_EffectsLayer1Tex("", 2D) = "black"{}
		_EffectsLayer1Color("", Color) = (1,1,1,1)
		_EffectsLayer1Motion("", 2D) = "black"{}
		_EffectsLayer1MotionSpeed("", float) = 0 
		_EffectsLayer1Rotation("", float) = 0
		_EffectsLayer1PivotScale("", Vector) = (0.5,0.5,1,1)
		_EffectsLayer1Translation("", Vector) = (0,0,0,0)
		_EffectsLayer1Foreground("", float) = 0
		}
	SubShader {
		Tags { "RenderType"="Transparent" 
		"Queue" = "Transparent"
		"PreviewType" = "Plane"
		}
		LOD 100
		ZWrite off
		Pass
		{
			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature EFFECTS_LAYER_1_OFF EFFECTS_LAYER_1_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};
			struct v2f
			{
				float4 vertex:SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 effect1uv:TEXCOORD1;
			};
				sampler2D _MainTex;
			sampler2D _DistTex;
			sampler2D _DistMask;

			sampler2D _EffectsLayer1Tex;
			sampler2D _EffectsLayer1Motion;
			float _EffectsLayer1MotionSpeed;
			float _EffectsLayer1Rotation;
			float4 _EffectsLayer1PivotScale;
			half4 _EffectsLayer1Color;
			float _EffectsLayer1Foreground;
			float2 _EffectsLayer1Translation;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				o.uv = v.uv;
				float2x2 rotationMatrix;
				float sinTheta;
				float cosTheta;
				o.effect1uv = o.uv - _EffectsLayer1PivotScale.xy;
				sinTheta = sin(_EffectsLayer1Rotation * _Time);
				cosTheta = cos(_EffectsLayer1Rotation * _Time);
				rotationMatrix = float2x2(cosTheta, -sinTheta, sinTheta, cosTheta);
				o.effect1uv = (mul( (o.effect1uv - _EffectsLayer1Translation.xy) *
					(1 / _EffectsLayer1PivotScale.zw), rotationMatrix)
					+ _EffectsLayer1PivotScale.xy);

				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				float2 distScroll = float2(_Time.x, _Time.x);
				fixed2 dist = (tex2D(_DistTex, i.uv + distScroll).rg - 0.5) * 2;
				fixed distMask = tex2D(_DistMask, i.uv)[0];

				fixed4 col = tex2D(_MainTex, i.uv + dist * distMask * 0.025);
				fixed bg = col.a;


				fixed4 motion1 = tex2D(_EffectsLayer1Motion, i.uv);

				if (_EffectsLayer1MotionSpeed)
					motion1.y -= _Time.x * _EffectsLayer1MotionSpeed;
				else
					motion1 = fixed4(i.effect1uv.rg, motion1.b, motion1.a);

				fixed4 effect1 = tex2D(_EffectsLayer1Tex, motion1.xy) * motion1.a;
				effect1 *= _EffectsLayer1Color;
				col += effect1 * effect1.a * max(bg, _EffectsLayer1Foreground);
				return col;
			}

			ENDCG
		}


	}
	FallBack "Diffuse"
	CustomEditor "GoldenMaterialEditor"
}
