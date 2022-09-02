Shader "Unlit/Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bump ("Bump Map",2D) = "white" {}
        _BumpScale ("Bump Scale",Float) = 1
        _AOMap ("AO Map",2D) = "white" {}
        _SpecMask ("Spec Mask",2D) = "white" {}
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
            float4 _LightColor0;
            float4 _SpecularColor;
            float _Gloss;

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
                float3 ligth_dir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = dot(bump,ligth_dir);
                float4 base_color = tex2D(_MainTex,i.uv);
                float4 ao_color = tex2D(_AOMap,i.uv);
                float4 spec_mask = tex2D(_SpecMask,i.uv);
                
                float3 diffuse = _LightColor0.xyz * base_color.xyz * (max(0.0,NdotL) * 0.9 + 0.1);
                float3 reflect_dir = normalize(2 * dot(bump,ligth_dir) * bump - ligth_dir);
                float3 specular = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0,dot(view_dir,reflect_dir)),_Gloss) * spec_mask;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                float3 final_color = (diffuse + specular + ambient) * ao_color;
                // sample the texture
                return float4(final_color,1.0);
            }
            ENDCG
        }
    }
}
