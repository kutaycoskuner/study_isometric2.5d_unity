// Pull in URP library functions and our own common functions
// ----------------------------------------------------------------------------
// imports
// ----------------------------------------------------------------------------
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "MapFunctions.hlsl"

// ----------------------------------------------------------------------------
// macros?
// ----------------------------------------------------------------------------
TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);  // rgb = albedo, a = alpha

// ----------------------------------------------------------------------------
// properties
// ----------------------------------------------------------------------------
float4 _ColorTint;
float4 _ColorMap_ST; // This is automatically set by Unity. Used in TRANSFORM_TEX to apply UV tiling
float _Smoothness;


// ----------------------------------------------------------------------------
// buffers
// ----------------------------------------------------------------------------
// This file contains the vertex and fragment functions for the forward lit pass
// This is the shader pass that computes visible colors for a material
// by reading material, light, shadow, etc. data

// This attributes struct receives data about the mesh we're currently rendering
// Data is automatically placed in fields according to their semantic
struct Attributes {
	float3 positionOS : POSITION; // Position in object space
	float2 uv : TEXCOORD0; // Material texture UVs
	float3 normalOS : NORMAL;
};

struct Interpolators {
	// This value should contain the position in clip space (which is similar to a position on screen)
	// when output from the vertex function. It will be transformed into pixel position of the current
	// fragment on the screen when read from the fragment function
	float4 positionCS : SV_POSITION;
	// The following variables will retain their values from the vertex stage, except the
	// rasterizer will interpolate them between vertices
	float2 uv : TEXCOORD0; // Material texture UVs
	float3 positionWS : TEXCOORD1;
	float3 normalWS : TEXCOORD2;
};

// ----------------------------------------------------------------------------
// functions
// ----------------------------------------------------------------------------
// The vertex function. This runs for each vertex on the mesh.
// It must output the position on the screen each vertex should appear at,
// as well as any data the fragment function will need
Interpolators Vertex(Attributes input) {
	Interpolators output;

	// These helper functions, found in URP/ShaderLib/ShaderVariablesFunctions.hlsl
	// transform object space values into world and clip space
	VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normInputs = GetVertexNormalInputs(input.normalOS);
	// Pass position and orientation data to the fragment function
	output.positionCS = posnInputs.positionCS;
	output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
	output.normalWS = normInputs.normalWS;
	output.positionWS = posnInputs.positionWS;
	return output;
}

// The fragment function. This runs once per fragment, which you can think of as a pixel on the screen
// It must output the final color of this pixel
float4 Fragment(Interpolators input) : SV_TARGET {

	// object input
	float2 uv = input.uv;
	float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
	float3 obj_albedo = colorSample.rgb * _ColorTint.rgb;
	float obj_alpha = colorSample.a * _ColorTint.a;

	// lighing input
	InputData lightingInput = (InputData)0;
	lightingInput.positionWS = input.positionWS;
	lightingInput.normalWS = normalize(input.normalWS);
	lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
	lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);

	// ambient light
	float3 ambientLight = float3(0.1, 0.12, 0.14);

	// surface calc
	SurfaceData surfaceInput = (SurfaceData)0;
	surfaceInput.albedo = obj_albedo;
	surfaceInput.alpha = obj_alpha;
	surfaceInput.specular = 1;
	surfaceInput.smoothness = _Smoothness;

	// ------------------------------------------------------------
	// Returns
	// ------------------------------------------------------------
	// #1 static white
	// return float4(1, 1, 1, 1); 		// static white color
	// #2 dynamic tint
	// return _ColorTint;				// color
	// #3 texture + color tint
	// return colorSample * _ColorTint;	// texture + color tint
	// #4 normals
	// return float4(input.normalWS, 1);
	// #5 0-1 normals
	// return float4(MaptoZeroOne(input.normalWS), 1);
	// #6
	#if UNITY_VERSION >= 202120
	return UniversalFragmentBlinnPhong(lightingInput, surfaceInput);
	#else
	return UniversalFragmentBlinnPhong(lightingInput, surfaceInput.albedo, float4(surfaceInput.specular, 1), surfaceInput.smoothness, 0, surfaceInput.alpha);
	#endif
}