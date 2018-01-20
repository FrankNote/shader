// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/spec" {
	Properties {
		_Diffuse ("_Diffuse", Color) = (1,1,1,1)
		_specular("_specular", Color) = (1,1,1,1)

		_Gloss ("Gloss", Range(0.0,256)) = 10
	}
	SubShader {
		pass {
			Tags{ "LightingMode" = "ForwardBase" } 
			LOD 200

			CGPROGRAM
			#include "Lighting.cginc" 
				fixed4 _Diffuse;
				fixed4 _specular;
				float _Gloss;
				struct a2v
				{
				 	float4 vertex:POSITION;
				 	float4 normal:NORMAL;
				};
				struct v2f
				{
					float4 pos:SV_POSITION;
					float3 worldNormal:NORMAL;
					float3 worldPos:TEXCOORD0;
				};
				v2f vert(a2v v)
				{
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					//worldNormal = normalize(worldNormal);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
					return o;
				}
				fixed4 frag(v2f i):SV_Target
				{
					fixed3 ambients =  UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse; 
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuses = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
					//镜面反射
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
					fixed3 halfDir = normalize(viewDir+worldLight);
					fixed3 speculars =  _LightColor0.rgb * _specular.rgb * pow(saturate(dot(halfDir,worldNormal)),_Gloss);
					fixed3 colors = ambients + diffuses + speculars;
					return fixed4(colors,1.0);
				}
				#pragma vertex vert
				#pragma fragment frag
			ENDCG
		}

	}
	FallBack "Diffuse"
}
