#ifndef _VL_CGINC__
#define _VL_CGINC__

#include "../Shadow/ShadowCommon.cginc"

uniform float4 _VolumetricLightForward; 
uniform float4 _VolumetricLightPos;
uniform float4 _VolumetricLightColor;

float3 RayMarch(float3 startPos, float3 viewDir, half3 normal)
{
    // 观察到的点与观察位置之间的向量
    float3 view2DestDir = startPos - _WorldSpaceCameraPos.xyz;

    // 观察到的点与观察位置之间的距离
    float view2DestDist= length(view2DestDir);

    // 以观察点与观察位置之间的距离为总的循环次数，每次递进 距离的倒数
    // 两种步进规则
    const int stepNum = 50;    //floor(view2DestDist)+1;
    float oneStep = view2DestDist / stepNum;    // 1 / stepNum

    float3 finalLight = 0;
    for (int k = 0; k < stepNum; k++)
    {
        // 采样的位置点
        float3 samplePos = startPos + viewDir * oneStep * k;     // * k ;

        // 累计递进的距离
        float stepDist = length(viewDir * oneStep * k);
        // 采样点到体积光源的位置的向量  指向光源
        float3 sample2Light = samplePos - _VolumetricLightPos.xyz;
        float3 sample2LightNorm = normalize(sample2Light);

        // 体积光源的照射方向和采样点到体积光源的方向的点积
        float litfrwdDotSmp2lit = dot(sample2LightNorm, _VolumetricLightForward.xyz);
        
        // angle为体积光的张角的一半，如果 litfrwdDotSmp2lit 大于 cos(angle) ，则表示该采样点在体积光范围内
        float isInLight = smoothstep((_VolumetricLightForward.w), 1, litfrwdDotSmp2lit);

        // 采样点到体积光源的距离
        float sample2LightDist = length(sample2Light) + 1;
        // 当距离小于于1 时 取倒数后光强会非常大，因此将得到得距离+1
        float sample2LightDistInv = 1.0 / sample2LightDist;
        
        // 采样点的光强， 与采样点到体积光源的距离平方成反比
        float sampleLigheIntensity = sample2LightDistInv * sample2LightDistInv * _VolumetricLightPos.w;

        // shadow
        float shadow = ShadowCalculation(float4(samplePos, 1));

        // final
        finalLight += _VolumetricLightColor.xyz * sampleLigheIntensity * isInLight * shadow; 
    }

    return finalLight;
}

#endif