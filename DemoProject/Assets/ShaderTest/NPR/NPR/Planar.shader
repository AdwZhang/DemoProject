Shader "Planar" {
    Properties {
		_ReflectionTex("Mirror Reflection",2D) = "white"{}
    }
    SubShader {
        Tags {
			"Queue" = "Transparent"
        }
        Pass {
			Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform float4 _Color;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 pos_world : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float4 screen_pos : TEXCOORD2;
            };


			sampler2D _ReflectionTex;

            v2f vert (appdata v) {
                v2f o = (v2f)0;
                o.pos_world = mul(unity_ObjectToWorld,v.vertex);
                o.normalDir = UnityObjectToWorldNormal(v.normal);         
				o.pos = UnityObjectToClipPos(v.vertex);
				o.screen_pos = o.pos;
                o.screen_pos.y = o.screen_pos.y * _ProjectionParams.x;
                return o;
            }
			half4 frag(v2f i) : SV_Target {
                float3 normalDir = normalize(i.normalDir);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.pos_world.xyz);
                float NdotV = saturate(dot(viewDir, normalDir));
				float fade_fresnel = smoothstep(0.05, 0.5, NdotV);

				 //计算平面倒影/镜子效果
				half2 screen_uv = i.screen_pos.xy /i.screen_pos.w;
				screen_uv = (screen_uv + 1.0) * 0.5; 
                float3 mirror_color = tex2D(_ReflectionTex, screen_uv);

                return float4(mirror_color, fade_fresnel);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
