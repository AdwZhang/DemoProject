Shader "Shader_Test/Char_Standard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "Bump" {}
        _CompMask ("CompMask", 2D) = "white" {}
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        _Gloss ("Gloss",Range(8.0,256)) = 20
        _EnvMap ("EnvMap", cube) = "white" {}
        _Expose ("Expose", float) = 1.0 
        _Oiliness ("Oiliness", Range(0,1)) = 1.0
        
        [HideInInspector] custom_SHAr ("Custom SHAr", Vector) = (0,0,0,0)
        [HideInInspector] custom_SHAg ("Custom SHAg", Vector) = (0,0,0,0)
        [HideInInspector] custom_SHAb ("Custom SHAb", Vector) = (0,0,0,0)
        [HideInInspector] custom_SHBr ("Custom SHBr", Vector) = (0,0,0,0)
        [HideInInspector] custom_SHBg ("Custom SHBg", Vector) = (0,0,0,0)
        [HideInInspector] custom_SHBb ("Custom SHBb", Vector) = (0,0,0,0)
        [HideInInspector] custom_SHC  ("Custom SHC", Vector) = (0,0,0,1)
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
                LIGHTING_COORDS(4,5)
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
            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            float _Expose;
            float _Oiliness;

            //SH
            half4 custom_SHAr;
            half4 custom_SHAg;
            half4 custom_SHAb;
            half4 custom_SHBr;
            half4 custom_SHBg;
            half4 custom_SHBb;
            half4 custom_SHC ;          

            float3 custom_sh(float3 normal_dir)
            {
                float4 normalForSH = float4(normal_dir,1.0);

                // SHEvalLinearL0L1
                half3 x;
                x.r = dot(custom_SHAr,normalForSH);
                x.g = dot(custom_SHAg,normalForSH);
                x.b = dot(custom_SHAb,normalForSH);
                
                // SHEvalLinearL2
                half3 x1,x2;
                
                // 4 of the quadratic (L2) polynomials
                half4 vB = normalForSH.xyzz * normalForSH.yzzx;
                x1.r = dot(custom_SHBr, vB);
                x1.g = dot(custom_SHBg, vB);
                x1.b = dot(custom_SHBb, vB);

                // Final (5th) quadratic (L2) polynomial
                half vC = normalForSH.x * normalForSH.x - normalForSH.y * normalForSH.y;
                x2 = custom_SHC.rgb * vC;
                
                float3 sh = max(float3(0.0, 0.0, 0.0),(x + x1 + x2));
                sh = pow(sh, 1.0 / 2.2);
                return sh;
            }

            inline float3 ACES_Tonemapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x+d) + e));
                return encode_color;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _NormalMap);
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;

                fixed3 tangent_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                fixed3 normal_world = UnityObjectToWorldDir(v.normal);
                fixed3 binormal_world = cross(tangent_world,normal_world) * v.tangent.w;

                o.TtoW0 = float4(tangent_world.x,binormal_world.x,normal_world.x,pos_world.x);
                o.TtoW1 = float4(tangent_world.y,binormal_world.y,normal_world.y,pos_world.y);
                o.TtoW2 = float4(tangent_world.z,binormal_world.z,normal_world.z,pos_world.z);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Texture Info
                half4 base_color_gamma = tex2D(_MainTex, i.uv.xy);
                half4 albedo_color = pow(base_color_gamma,2.2);
                half3 normal_dir = UnpackNormal(tex2D(_NormalMap, i.uv.zw));
                half4 comp_mask = tex2D(_CompMask,i.uv.xy);
                half roughness = comp_mask.r;
                half metal = comp_mask.g;   // 金属度
                half skin_area = 1 - comp_mask.b; // 是否是皮肤区
                half3 base_color = albedo_color.rgb * (1 - metal);      // 固有色
                half3 spec_color = lerp(0.04, albedo_color.rgb,metal);  // 高光色
                // Dir
                float3 world_pos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                float3x3 TBN = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
                normal_dir = normalize(mul(TBN,normal_dir));
                float3 view_dir = normalize(UnityWorldSpaceViewDir(world_pos));
                float3 light_dir = normalize(UnityWorldSpaceLightDir(world_pos));

                // Light
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                half atten = LIGHT_ATTENUATION(i);      //光照衰减
                
                // Direct Diffuse 直接光漫反射
                half diff_term = saturate(dot(normal_dir,light_dir));
                float3 direct_diffuse = _LightColor0.xyz * base_color * diff_term * atten;

                // Direct Specular 直接光镜面反射
                float3 half_dir = normalize(view_dir + light_dir);
                half NdotH = dot(normal_dir,half_dir);
                half smoothness = 1.0 - roughness;
                smoothness = lerp(1, _Gloss, smoothness);
                half spec_term = pow(saturate(NdotH),smoothness);
                half3 spec_skin_color = lerp(spec_color,_Oiliness, skin_area);
                float3 specular = _LightColor0.xyz * spec_skin_color * spec_term * atten;

                // Indirect Diffuse 间接光的漫反射
                half half_lambert = (diff_term + 1.0) * 0.5;
                float3 env_diffuse = custom_sh(normal_dir) * base_color * half_lambert;

                // Indirect Specular 间接光的镜面反射
                half3 reflect_dir = reflect(-view_dir,normal_dir);
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_EnvMap,float4(reflect_dir,mip_level));
                half3 env_color = DecodeHDR(color_cubemap,_EnvMap_HDR);
                half3 env_specular = env_color * _Expose * spec_color * half_lambert;
                
                float3 final_color = direct_diffuse + specular + env_diffuse + env_specular;
                final_color = ACES_Tonemapping(final_color);
                final_color = final_color;
                final_color = pow(final_color,1.0 / 2.2);
                
                return fixed4(final_color , 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
