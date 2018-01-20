Shader "Custom/lightTest" {
	Properties {
		_Diffuse("Diffuse",color) = (1,1,1,1)

	}
	SubShader {
		pass {
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM
			#include "Lighting.cginc" 
				fixed4 _Diffuse;
				struct a2v
				{
				 	float4 vertex:POSITION;
				 	float4 normal:NORMAL;
				};
				struct v2f
				{
					float4 pos:SV_POSITION;
					fixed4 color:COLOR;
				};
				v2f vert(a2v v)
				{
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
					float3 worldNormal = UnityObjectToWorldNormal(v.normal);
					worldNormal = normalize(worldNormal);
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 lamber = max(0,dot(worldNormal,worldLightDir));
					o.color = fixed4(lamber*_Diffuse.xyz*_LightColor0.xyz,1.0);
					return o;
				}
				fixed4 frag(v2f i):SV_Target
				{
					return i.color;
				}
				#pragma vertex vert
				#pragma fragment frag
			ENDCG
		}

	}
	FallBack "Diffuse"
}
