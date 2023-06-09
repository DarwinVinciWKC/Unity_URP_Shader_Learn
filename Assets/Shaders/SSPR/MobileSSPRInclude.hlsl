//see README here: https://github.com/ColinLeung-NiloCat/UnityURP-MobileScreenSpacePlanarReflection
#ifndef MobileSSPRInclude
#define MobileSSPRInclude

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//textures         
TEXTURE2D(_MobileSSPR_ColorRT);
sampler LinearClampSampler;

struct ReflectionInput
{
    half3 posWS;
    half3 normalWS;
    half4 screenPos;
    half roughness;
    half SSPR_Usage;
};
half3 GetResultReflection(ReflectionInput data) 
{ 
    //sample scene's reflection probe
    half3 viewWS = (_WorldSpaceCameraPos.xyz-data.posWS);
    //half3 viewWS = (data.posWS-_WorldSpaceCameraPos.xyz);
    viewWS = normalize(viewWS);

    //half3 reflectDirWS = viewWS * half3(1,-1,1);//reflect at horizontal plane
    half3 reflectDirWS =reflect(-viewWS,data.normalWS);//reflect at horizontal plane

    //call this function in Lighting.hlsl-> half3 GlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion)
    half3 reflectionProbeResult = GlossyEnvironmentReflection(reflectDirWS,data.roughness,half(1.0));               
    half4 SSPRResult = 0;
#if _MobileSSPR    
    half2 screenUV = data.screenPos.xy/data.screenPos.w;
    SSPRResult = SAMPLE_TEXTURE2D(_MobileSSPR_ColorRT,LinearClampSampler, screenUV); //use LinearClampSampler to make it blurry
#endif

    //final reflection
    half3 finalReflection = lerp(reflectionProbeResult,SSPRResult.rgb, SSPRResult.a * data.SSPR_Usage);//combine reflection probe and SSPR

    return finalReflection;
}
#endif
