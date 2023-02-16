Shader "NPR/NprHero"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _SssMap ("SSS Map", 2D) = "black" {}
        _ILM ("ILM Map", 2D) = "gray" {}
        _ToonThesHold ("ToonThesHold", Range(0,1)) = 0.5
        _ToonHardness ("ToonHardness", Float) = 20.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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
            float _ToonThesHold;
            float _ToonHardness;

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

                // base贴图
                fixed4 base_map = tex2D(_BaseMap, uv1);
                fixed3 base_color = base_map.rgb;                   // 亮部的颜色
                // SSS贴图
                fixed4 sss_map = tex2D(_SssMap, uv1);
                fixed3 sss_color = sss_map.rgb;                     // 暗部的颜色
                // ILM 贴图
                fixed4 ilm_map = tex2D(_ILM, uv1);
                float spec_intensity = ilm_map.r;                   // 控制高光强度
                float diffuse_control = ilm_map.g * 2.0 - 1.0;      // 控制光照的偏移
                float spec_size = ilm_map.b;                        // 控制高光的形状大小
                float inner_line = ilm_map.a;                       // 内描线
                // 顶点色
                float ao = i.vertex_color.r;
                
                // 漫反射
                half NdotL = dot(normal_dir,light_dir);
                half half_lambert = (NdotL + 1.0) * 0.5;
                half lambert_term = half_lambert * ao    + diffuse_control;
                half toon_diffuse = saturate((lambert_term - _ToonThesHold) * _ToonHardness);
                fixed3 diffuse_color = lerp(sss_color,base_color,toon_diffuse);

                fixed3 final_color = diffuse_color;
                
                return fixed4(final_color,1.0);
            }
            ENDCG
        }
    }
}
