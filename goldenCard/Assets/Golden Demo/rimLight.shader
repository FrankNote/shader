Shader "Custom/rimLight" {
	Properties {
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_RimColor("RimColor",Color) = (1,1,1,1)
		_RimPower("RimPower",Range(0.000001,3.0)) = 0.1
		_MainTex("Base 2D",2D) = "white"{}
	}
	SubShader {
		pass{
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM
			#include "Lighting.cginc"
			fixed4 _Diffuse;
			fixed4 _RimColor;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			half _RimPower;

			struct v2f
			{
				half4 pos:SV_POSITION;
				half3 worldNormal:TEXCOORD0;
				half2 uv:TEXCOORD1;
				half3 worldViewDir:TEXCOORD2; 
			};
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				half3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir = _WorldSpaceCameraPos.xyz - worldPos;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz; 
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				half3 lambert  = 0.5 + 0.5 * dot(worldNormal,worldLightDir);
				half3 diffusesss = lambert * _LightColor0.xyz * _Diffuse.xyz + ambient;
				fixed4 texColor = tex2D(_MainTex,i.uv);
				half3 wViewDir  = normalize(i.worldViewDir);
				half rim = 1 - max(0,dot(wViewDir,worldNormal));
				fixed3 rimColor = _RimColor * pow(rim,1 / _RimPower);
				texColor.rgb = diffusesss * texColor.rgb + rimColor;
			
				return fixed4(texColor);
			}
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

	}
	FallBack "Diffuse"
}
