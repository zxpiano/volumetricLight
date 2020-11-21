Shader "ZxP/ShadowCaster"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
    }

	SubShader{
		Tags{
			"RenderType" = "Opaque"
		}
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float2 depth:TEXCOORD0;
                float2 uv : TEXCOORD1;
			};

			float _LightShadowBiasZ;
			float _LightShadowBiasX;

            sampler2D _MainTex;

			v2f vert(appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				if (_LightShadowBiasZ != 0.0)
				{
					float3 wNormal = UnityObjectToWorldNormal(v.normal);
					float3 wLight = normalize(UnityWorldSpaceLightDir(worldPos));
					float shadowCos = dot(wNormal, wLight);
					float shadowSine = sqrt(1 - shadowCos*shadowCos);
					float normalBias = _LightShadowBiasZ * shadowSine;

					worldPos.xyz -= wNormal *normalBias;
				}

				float4 clipPos = mul(UNITY_MATRIX_VP, worldPos);
				o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				float depth = i.pos.z;
				
#if defined (UNITY_REVERSED_Z)
				depth = 1 - depth;       //(1, 0)-->(0, 1)
#endif

				return depth;
			}
			ENDCG
		}
	}
}
