Shader "Kutay/FreyaShader"
{
	Properties
	{
		// color, texture
		//_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		//LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "../Custom/MapFunctions.hlsl"


			// mesh data: vertex pos, vertex normal, uvs, tangents, vertex colors
			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//float4 colors : COLOR;
				//float4 tangent : TANGENT;
				//float2 uv0 : TEXCOORD0;
				//float2 uv1 : TEXCOORD1;
			};

			struct vertexOutput
			{
				float4 clipSpacePos : SV_POSITION; // sv is special semantic
				float3 normal : NORMAL;
			};

			// ----- variables tied to proerties
			//sampler2D _MainTex;
			//float4 _MainTex_ST;

			vertexOutput vert(vertexInput i)
			{
				vertexOutput o;
				o.normal = i.normal;
				o.clipSpacePos = UnityObjectToClipPos(i.vertex);
				return o;
			}

			fixed4 frag(vertexOutput o) : SV_Target
			{

				// -- static light
				// float3 lightDir = normalize( float3(-1, 1, 1) ); // normalize vektor boyunu 1 e mapliyor
				// float3 lightCol = BytetoOne(float3(243, 211, 211));
				// float3 lightCol = float3(0.9, 0.82, 0.76);

				// -- scene light
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 lightCol = _LightColor0.rgb;

				float lightFalloff = max(0, dot(lightDir, o.normal)); // max 0, clamping value to 0

				float3 diffuseLight = lightCol * lightFalloff;
				float3 ambientLight = float3(0.1, 0.12, 0.14);
				// lambert shading

				float3 mappedNormal = MaptoZeroOne(o.normal);
				return float4(diffuseLight, 0);
				//return col;
			}
			ENDCG
		}
	}
}
