Shader "Custom/motionBlur" {
	Properties {
		_MainTex ("mainTex (RGB)", 2D) = "white" {}
		_IterationNumber("loopTime",float) = 16
		_Intensity("rate",float) = 0.3
		//_center("point",Vector) = (0.5f,0.5f);
	}
	SubShader {
		pass
		{
			ZTest Always
			CGPROGRAM
			//#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			uniform Vector center;
			uniform float _Intensity;
			uniform float _IterationNumber;

			struct a2v
			{
				float4 vertex : POSITION;//顶点位置
				fixed4 texcoord:TEXCOORD0;
				float4 color : COLOR;//颜色值  
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed2 texcoord:TEXCOORD0;
				fixed4 color : COLOR;//颜色值
			};
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex); 
				o.texcoord = v.texcoord;
				 o.color = v.color; 
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				float2 dir = i.texcoord.xy - center;
				float4 outColor = 0;
				float scale = 1;
				_Intensity *= 0.0085;
				for(int i = 0;i<_IterationNumber;i++)
				{
					outColor += tex2D(_MainTex,dir*scale+center);
					scale = 1+(float(i*_Intensity));
				}
				outColor /= (float)_IterationNumber;
				return outColor;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
