// Upgrade NOTE: replaced 'defined DIRECTIONAL' with 'defined (DIRECTIONAL)'

Shader "Unlit/Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bump ("Bump Map",2D) = "white" {}
        _BumpScale ("Bump Scale",Range(0,5)) = 1
        _AOMap ("AO Map",2D) = "white" {}
        _SpecMask ("Spec Mask",2D) = "white" {}
        _HeightMap ("Height Map",2D) = "white" {}
        _HeightScale ("Height Scale",Range(-0.1,0.1)) = 0
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
            // Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
            #pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 TtoW0 : TEXTCOORD1;
                float4 TtoW1 : TEXTCOORD2;
                float4 TtoW2 : TEXTCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bump;
            float _BumpScale;
            sampler2D _AOMap;
            sampler2D _SpecMask;
            sampler2D _HeightMap;
            float _HeightScale;
            float4 _LightColor0;
            float4 _SpecularColor;
            float _Gloss;

            float2 ParallaxMapping(float2 texcoords, float3 viewDir)
            {
                half height = tex2D(_HeightMap,texcoords).r;
                height = 1.0f - height;
                float2 p = viewDir.xy / viewDir.z * (height * _HeightScale);
                texcoords = texcoords + p;
                return texcoords;
            }

            // 色调映射
            float3 ACESFilm(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                
                return saturate((x * (a*x + b)) / (x*(c*x + d) + e));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 normal_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                fixed3 tangent_world = UnityObjectToWorldDir(v.tangent);
                fixed3 binormal_world = cross(normal_world,tangent_world) * v.tangent.w; 

                o.TtoW0 = float4(tangent_world.x,binormal_world.x,normal_world.x,pos_world.x);
                o.TtoW1 = float4(tangent_world.y,binormal_world.y,normal_world.y,pos_world.y);
                o.TtoW2 = float4(tangent_world.z,binormal_world.z,normal_world.z,pos_world.z);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half shadow = SHADOW_ATTENUATION(i);
                float3 pos_world = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - pos_world);
                float3 ligth_dir = normalize(_WorldSpaceLightPos0.xyz);

                float3x3 TBN = float3x3(normalize(i.TtoW0.xyz),normalize(i.TtoW1.xyz),normalize(i.TtoW2.xyz)); 
                
                float3 view_dir_tangent_space = normalize(mul(view_dir,TBN));
                float2 texcoords = ParallaxMapping(i.uv,view_dir_tangent_space);
                /*float2 texcoords = i.uv;
                for(int k = 0; k < 10; k++)
                {
                    half height = tex2D(_HeightMap,texcoords);
                    texcoords = texcoords + (1.0 - height) * view_dir_tangent_space.xy * _HeightScale;
                }*/
                
                fixed3 bump = UnpackNormal(tex2D(_Bump,texcoords));
                bump.xy *= _BumpScale;
                //bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));
                //bump = normalize(fixed3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                bump = normalize(mul(TBN,bump));
                           
                float NdotL = dot(bump,ligth_dir);
                float4 base_color = tex2D(_MainTex,texcoords);
                //base_color = pow(base_color,2.2);     // 转换为线性空间
                float4 ao_color = tex2D(_AOMap,texcoords); 
                float4 spec_mask = tex2D(_SpecMask,texcoords);
                //spec_mask = float4(1.0,1.0,1.0,1.0) - spec_mask;
                
                float3 diffuse = _LightColor0.xyz * base_color.xyz * (max(0.0,NdotL) * 0.9 + 0.1);
                float3 reflect_dir = normalize(2 * dot(bump,ligth_dir) * bump - ligth_dir);
                float3 specular = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0,dot(view_dir,reflect_dir)),_Gloss) * spec_mask;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * base_color.xyz;
                float3 final_color = (diffuse + specular + ambient) * ao_color;
                // sample the texture
                
                //half shadow = SHADOW_ATTENUATION(i);
                float3 tone_color = ACESFilm(final_color);
                tone_color = pow(tone_color,1/2.2);   // 转换为Gamma空间
                return float4(final_color,1.0);
            }
            ENDCG
        }
        
/*        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 TtoW0 : TEXTCOORD1;
                float4 TtoW1 : TEXTCOORD2;
                float4 TtoW2 : TEXTCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bump;
            float _BumpScale;
            sampler2D _AOMap;
            sampler2D _SpecMask;
            sampler2D _HeightMap;
            float _HeightScale;
            float4 _LightColor0;
            float4 _SpecularColor;
            float _Gloss;

            float2 ParallaxMapping(float2 texcoords, float3 viewDir)
            {
                float height = tex2D(_HeightMap,texcoords);
                float2 p = viewDir.xy/viewDir.z * (height * _HeightScale);
                return texcoords - p;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 normal_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                fixed3 tangent_world = UnityObjectToWorldDir(v.tangent);
                fixed3 binormal_world = cross(normal_world,tangent_world) * v.tangent.w; 

                o.TtoW0 = float4(tangent_world.x,binormal_world.x,normal_world.x,pos_world.x);
                o.TtoW1 = float4(tangent_world.y,binormal_world.y,normal_world.y,pos_world.y);
                o.TtoW2 = float4(tangent_world.z,binormal_world.z,normal_world.z,pos_world.z);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 pos_world = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 bump = UnpackNormal(tex2D(_Bump,i.uv));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));
                bump = normalize(fixed3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                           
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - pos_world);
                #if defined (DIRECTIONAL) 
                float3 ligth_dir = normalize(_WorldSpaceLightPos0.xyz);
                float attuenation = 1.0;
                #elif defined (POINT) 
                float3 ligth_dir = normalize(_WorldSpaceLightPos0.xyz);
                half distance = length(_WorldSpaceLightPos0.xyz - pos_world);
                half range = 1.0 / unity_WorldToLight[0][0];
                float attuenation = saturate(range - distance) / range;
                //attuenation = 0;
                #endif
                float NdotL = dot(bump,ligth_dir);
                float4 base_color = tex2D(_MainTex,i.uv);
                float4 ao_color = tex2D(_AOMap,i.uv); 
                float4 spec_mask = tex2D(_SpecMask,i.uv);
                spec_mask = float4(1.0,1.0,1.0,1.0) - spec_mask;
                
                float3 diffuse = _LightColor0.xyz * base_color.xyz * (max(0.0,NdotL) * 0.9 + 0.1) * attuenation;
                float3 reflect_dir = normalize(2 * dot(bump,ligth_dir) * bump - ligth_dir);
                float3 specular = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0,dot(view_dir,reflect_dir)),_Gloss) * spec_mask.rgb * attuenation;
                fixed3 ambient = fixed3(0,0,0);
                float3 final_color = (diffuse + specular + ambient) * ao_color;
                // sample the texture
                return float4(final_color,1.0);
            }
            ENDCG
        }*/

    }
    Fallback "Diffuse"
}
