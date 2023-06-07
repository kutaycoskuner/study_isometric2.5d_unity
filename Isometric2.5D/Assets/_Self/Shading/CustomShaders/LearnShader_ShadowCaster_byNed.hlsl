// ----------------------------------------------------------------------------
// imports
// ----------------------------------------------------------------------------
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// ----------------------------------------------------------------------------
// macros?
// ----------------------------------------------------------------------------
TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);  // rgb = albedo, a = alpha

// ----------------------------------------------------------------------------
// properties
// ----------------------------------------------------------------------------
float3 _LightDirection;

// ----------------------------------------------------------------------------
// buffers
// ----------------------------------------------------------------------------
struct Attributes {
	float3 positionOS : POSITION;
	float3 normalOS	  : NORMAL;
};

struct Interpolators {
	float4 positionCS : SV_POSITION;
};

// ----------------------------------------------------------------------------
// functions
// ----------------------------------------------------------------------------
float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS) 
{
	float3 lightDirectionWS = _LightDirection;
	float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
	#if UNITY_REVERSED_Z
		positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
	#else
		positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
	#endif
	return positionCS;
}


Interpolators Vertex(Attributes input) {
	Interpolators output;

	VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normInputs = GetVertexNormalInputs(input.normalOS);

	output.positionCS = GetShadowCasterPositionCS(posnInputs.positionWS, normInputs.normalWS);
	return output;
}

float4 Fragment(Interpolators input) : SV_TARGET
{
	return 0;
}