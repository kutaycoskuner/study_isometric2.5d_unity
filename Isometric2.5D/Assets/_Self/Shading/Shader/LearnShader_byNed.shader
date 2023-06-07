Shader "Kutay/NedShader"
{
    Properties
    {
        [Header(Surface options)] // Creates a text header
        // [MainColor] allows Material.color to use the correct property
        [MainTexture] _ColorMap("Texture", 2D) = "white" {}
        [MainColor] _ColorTint("Tint", Color) = (1, 1, 1, 1)
        _Smoothness("Smoothness", Float) = 0
    }

    Subshader
    {
        Tags{"RenderPipeline" = "UniversalPipeline"}
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "../Custom/NedShaderShadowCaster.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ForwardLit" // for debugging
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM

            #define _SPECULAR_COLOR
            
            #if UNITY_VERSION >= 202120
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #else
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #endif
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            
            #pragma vertex Vertex
            #pragma fragment Fragment


            #include "../Custom/NedShader.hlsl"

            ENDHLSL
        }

    }   
}