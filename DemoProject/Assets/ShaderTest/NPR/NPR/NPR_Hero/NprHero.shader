Shader "NPR/NprHero"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _SssMap ("SSS Map", 2D) = "black" {}
        _ILM ("ILM Map", 2D) = "gray" {}
        _Detail ("Detail Map", 2D) = "white" {}
        _ToonThesHold ("ToonThesHold", Range(0,1)) = 0.5
        _ToonHardness ("ToonHardness", Float) = 20.0
        _SpecSize ("Spec Size", Range(0,1)) = 0.1
        _SpecColor ("Spec Color", COLOR) = (1,1,1,1)
        _OutlineSize ("Outline Size", Float) = 0.0
        _OutlineColor ("Outline Color", COLOR) = (1,1,1,1)
        _OutlineZbias ("Outline Zbias",Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }

        Pass
        {
            Cull Front
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 texcoord0 : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float _OutlineSize;
            sampler2D _BaseMap;
            float4 _OutlineColor;
            float _OutlineZbias;
            
            v2f vert (appdata v)
            {
                v2f o;

                float3 pos_view = UnityObjectToViewPos(v.vertex);
                float3 normal_world = UnityObjectToWorldNormal(v.normal);
                float3 outline_dir = normalize(mul((float3x3)UNITY_MATRIX_V, normal_world));
                outline_dir.z = _OutlineZbias * (1.0 - v.color.b);
                pos_view += outline_dir * _OutlineSize * 0.001 * v.color.a;
                o.pos = mul(UNITY_MATRIX_P, float4(pos_view, 1.0));
                o.uv = v.texcoord0;
                /*float3 world_pos = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 world_normal = UnityObjectToWorldNormal(v.normal);
                world_pos += world_normal * _OutlineSize * 0.001;
                o.pos = UnityWorldToClipPos(float4(world_pos,1.0));*/
                //o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 baseColor = tex2D(_BaseMap, i.uv).xyz;
                half maxComponent = max(max(baseColor.r,baseColor.g),baseColor.b) - 0.004;
                half3 saturateColor = step(maxComponent.rrr, baseColor) * baseColor;
                saturateColor = lerp(baseColor, saturateColor, 0.6);
                half3 outlineColor = 0.8 * saturateColor * baseColor * _OutlineColor.xyz;
                return fixed4(outlineColor, 1.0);
            }
            
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                float3 world_normal : TEXCOORD2;
                float4 vertex_color : TEXCOORD3;
            };

            sampler2D _BaseMap;
            float4 _BaseMap_ST;
            sampler2D _SssMap;
            float4 _SssMap_ST;
            sampler2D _ILM;
            float4 _ILM_ST;
            sampler2D _Detail;
            float _ToonThesHold;
            float _ToonHardness;
            float _SpecSize;
            float4 _SpecColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = float4(v.texcoord0, v.texcoord1);
                o.world_pos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                o.vertex_color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv1 = i.uv.xy;
                float2 uv2 = i.uv.zw;
                // 向量
                half3 light_dir = normalize(_WorldSpaceLightPos0);
                half3 normal_dir = normalize(i.world_normal);
                half3 view_dir = normalize(_WorldSpaceCameraPos - i.world_pos);

                // base贴图
                fixed4 base_map = tex2D(_BaseMap, uv1);
                fixed3 base_color = base_map.rgb;                   // 亮部的颜色
                // SSS贴图
                fixed4 sss_map = tex2D(_SssMap, uv1);
                fixed3 sss_color = sss_map.rgb;                     // 暗部的颜色
                // ILM贴图
                fixed4 ilm_map = tex2D(_ILM, uv1);
                float spec_intensity = ilm_map.r;                   // 控制高光强度
                float diffuse_control = ilm_map.g * 2.0 - 1.0;      // 控制光照的偏移
                float spec_size = ilm_map.b;                        // 控制高光的形状大小
                float inner_line = ilm_map.a;                       // 内描线
                // Detail贴图
                float3 detail_color = tex2D(_Detail,uv2).rgb;
                // 顶点色
                float ao = i.vertex_color.r;
                
                // 漫反射
                half NdotL = dot(normal_dir,light_dir);
                half half_lambert = (NdotL + 1.0) * 0.5;
                half lambert_term = half_lambert * ao + diffuse_control;
                half toon_diffuse = saturate((lambert_term - _ToonThesHold) * _ToonHardness);
                fixed3 diffuse_color = lerp(sss_color,base_color,toon_diffuse);

                // 高光
                float NdotV = dot(normal_dir,view_dir);
                float spec_term = NdotV * ao + diffuse_control;
                spec_term = lambert_term * 0.9 + spec_term * 0.1;
                half toon_spec = saturate((spec_term - (1.0 - spec_size * _SpecSize)) * 500);
                half3 spec_color = (_SpecColor.rgb + base_color) * 0.5;
                spec_color = toon_spec * spec_color * spec_intensity;

                // 描线
                half3 final_line = inner_line.xxx * detail_color;
                fixed3 final_color = (diffuse_color + spec_color) * final_line;
                final_color = sqrt(max(exp2(log2(max(final_color,0.0))* 2.2), 0.0));
                return fixed4(final_color,1.0);
            }
            ENDCG
        }
    }
}
