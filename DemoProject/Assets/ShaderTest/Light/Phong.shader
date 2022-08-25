Shader "Unlit/Phong"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_world : TEXTCOORD1;
                float3 pos_world : TEXCOORD2;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Diffuse;
            float4 _LightColor0;
            float4 _SpecularColor;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                o.pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal_dir = normalize(i.normal_world);
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                float3 ligth_dir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = dot(normal_dir,ligth_dir);
                float4 tex = tex2D(_MainTex,i.uv);
                float3 diffuse = _LightColor0.xyz * tex.xyz * (max(0.0,NdotL) * 0.9 + 0.1);
                float3 reflect_dir = normalize(2 * dot(normal_dir,ligth_dir) * normal_dir - ligth_dir);
                float3 specular = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0,dot(view_dir,reflect_dir)),_Gloss);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                // sample the texture
                return float4(diffuse + specular + ambient,1.0);
            }
            ENDCG
        }
    }
}
