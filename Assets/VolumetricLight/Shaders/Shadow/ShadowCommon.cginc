

#ifndef _SHADOW_COMMON_CGINC__
#define _SHADOW_COMMON_CGINC__

float4 _VLightDepthTex_TexelSize;
uniform sampler2D _VLightDepthTex;
uniform float4x4 _WorldToShadow;

float ShadowCalculation(float4 wPos)
{
    float4 shadowCoord = mul(_WorldToShadow, wPos);
    shadowCoord.xyz /= shadowCoord.w;
    shadowCoord.xy = shadowCoord.xy * 0.5 + 0.5;

    float closestDepth = tex2D(_VLightDepthTex, shadowCoord.xy).r; 

    float currentDepth = shadowCoord.z;

#if defined (UNITY_REVERSED_Z)
    currentDepth = 1 - currentDepth;       //(1, 0)-->(0, 1)
#endif

    float bias = 0.0005;
    float shadow = currentDepth - bias > closestDepth ? 0 : 1;

    float2 texelSize = _VLightDepthTex_TexelSize.xy * 1;
    shadow = 0;
    for (int i = -1; i <= 1; i++)
    {
        for (int j = -1; j <= 1; j++)
        {
            float pcfDepth = tex2D(_VLightDepthTex, shadowCoord.xy + float2(i, j) * texelSize).r;// .r;
            shadow += currentDepth - bias > pcfDepth ? 0 : 1;
        }
    }
    shadow /= 9;

    if (currentDepth > 1 || currentDepth < 0)
    {
        shadow = 1;
    }

    return shadow;
}

#endif