Shader "Shader_Test/Char_Standard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "Bump" {}
        _CompMask ("CompMask", 2D) = "white" {}
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        _Gloss ("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 TtoW0 : TEXTCOORD1;
                float4 TtoW1 : TEXTCOORD2;
                float4 TtoW2 : TEXTCOORD3;
                SHADOW_COORDS(5)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _CompMask;
            float4 _CompMask_ST;
            float4 _LightColor0;
            float4 _SpecularColor;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _NormalMap);
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;

                fixed3 tangent_world = UnityObjectToWorldDir(v.tangent);
                fixed3 normal_world = UnityObjectToWorldDir(v.normal);
                fixed3 binormal_world = cross(tangent_world,normal_world) * v.tangent.w;

                o.TtoW0 = float4(tangent_world.x,binormal_world.x,normal_world.x,pos_world.x);
                o.TtoW1 = float4(tangent_world.y,binormal_world.y,normal_world.y,pos_world.y);
                o.TtoW2 = float4(tangent_world.z,binormal_world.z,normal_world.z,pos_world.z);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half shadow = SHADOW_ATTENUATION(i);
                // Texture Info
                half4 base_color_gamma = tex2D(_MainTex, i.uv.xy);
                half4 albedo_color = pow(base_color_gamma,2.2);
                half3 normal = UnpackNormal(tex2D(_NormalMap, i.uv.zw));
                half4 comp_mask = tex2D(_CompMask,i.uv.xy);
                half roughness = comp_mask.r;
                half metal = comp_mask.g;   // 金属度
                half3 base_color = albedo_color.rgb * (1 - metal);      // 固有色
                half3 spec_color = lerp(0.04, albedo_color.rgb,metal);  // 高光色
                // Dir
                float3 world_pos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                float3x3 TBN = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
                normal = normalize(mul(TBN,normal));
                float3 view_dir = normalize(UnityWorldSpaceViewDir(world_pos));
                float3 light_dir = normalize(UnityWorldSpaceLightDir(world_pos));

                // Light
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                half atten = LIGHT_ATTENUATION(i);      //光照衰减
                // atten = 1.0;
                // Direct Diffuse 直接光漫反射
                half diff_term = 0.5 + 0.5 * saturate(dot(normal,light_dir));
                float3 diffuse = _LightColor0.xyz * base_color * diff_term * atten;

                // Direct Specular 直接光镜面反射
                float3 half_dir = normalize(normal + light_dir);
                half NdotH = dot(normal,half_dir);
                half smoothness = 1.0 - roughness;
                smoothness = lerp(1, _Gloss, smoothness);
                half spec_term = pow(saturate(NdotH),smoothness);
                float3 specular = _LightColor0.xyz * spec_color * spec_term * atten;

                float3 final_color = diffuse + specular;
                
                return fixed4(diffuse,1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
