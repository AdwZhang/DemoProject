Shader "JadeShader"
{
    Properties
    {
        [Header(EnvReflect)]
        _BasePassDistortion ("Base Pass Distortion", Range(0,1)) = 0.0
        _BasePassPower ("Base Pass Power", Float) = 1.0
        _BasePassScale ("Base Pass Scale", Float) = 1.0
        _CubeMap ("CubeMap", Cube) = "white" {}
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
        _Thickness ("Thickness", 2D) = "black" {}
        
        _AddColor ("AddColor", Color) = (1,1,1,1)
    }
    SubShader
    {

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
            };

            float _BasePassDistortion;
            float _BasePassPower;
            float _BasePassScale;
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            float4 _DiffuseColor;
            sampler2D _Thickness;
            float4 _LightColor0;
            float4 _AddColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.pos_world = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 view_dir = normalize(UnityWorldSpaceViewDir(i.pos_world));
                float3 light_dir = normalize(UnityWorldSpaceLightDir(i.pos_world));
                float3 normal_dir = normalize(i.normal_world);
                float3 reflect_dir = reflect(-view_dir,normal_dir);

                // 透射光
                float3 back_dir = - normalize(light_dir + normal_dir * _BasePassDistortion);
                float VdotB = max(0.0, dot(view_dir,back_dir));
                float backlight_term = pow(VdotB,_BasePassPower) * _BasePassScale;
                float thickness = tex2D(_Thickness,i.uv).r;
                thickness = 1 - thickness;
                float3 back_color = _LightColor0.rgb * backlight_term * thickness;
                
                // 漫反射
                float diffuse_term = max(0.0,dot(normal_dir,light_dir));
                float3 diffuse_light_color = _LightColor0.rgb * _DiffuseColor * 0;
                float3 final_diffuse = diffuse_light_color + _AddColor.xyz * thickness;

                // 光泽反射
                float4 color_cubemap = texCUBE(_CubeMap,reflect_dir);
                float3 env_color = DecodeHDR(color_cubemap,_CubeMap_HDR);

                //fresnel
                float fresnel = 1.0 - max(0.0,dot(normal_dir,view_dir));
                env_color = env_color * fresnel;
                
                fixed3 final_color = env_color + back_color + final_diffuse;
                
                return fixed4(final_color,1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };

            float _BasePassDistortion;
            float _BasePassPower;
            float _BasePassScale;
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            float4 _DiffuseColor;
            sampler2D _Thickness;
            float4 _LightColor0;
            float4 _AddColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.pos_world = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 view_dir = normalize(UnityWorldSpaceViewDir(i.pos_world));
                float3 light_dir = normalize(UnityWorldSpaceLightDir(i.pos_world));
                float3 normal_dir = normalize(i.normal_world);
                float attenuation = LIGHT_ATTENUATION(i);
                // 透射光
                float3 back_dir = - normalize(light_dir + normal_dir * _BasePassDistortion);
                float VdotB = max(0.0,dot(view_dir,back_dir));
                float backlight_term = pow(VdotB,_BasePassPower) * _BasePassScale;
                float thickness = tex2D(_Thickness,i.uv).r;
                thickness = 1 - thickness;
                float3 back_color = _LightColor0.rgb * backlight_term * thickness;
                
                // 漫反射
                float diffuse_term = max(0.0,dot(normal_dir,light_dir)) * 0.5;
                float3 diffuse_light_color = _LightColor0.rgb * _DiffuseColor * diffuse_term;
                float3 final_diffuse = diffuse_light_color;

                fixed3 final_color = back_color + final_diffuse;
                final_color = final_color * attenuation;
                return fixed4(final_color,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
