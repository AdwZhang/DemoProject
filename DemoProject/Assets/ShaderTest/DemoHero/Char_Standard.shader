Shader "Shader_Test/Char_Standard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "Bump" {}
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 world_normal : TEXCOORD1;
                float3 world_pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                o.world_pos = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                fixed4 diffuse = tex2D(_MainTex, i.uv);
                float3 light_dir = normalize(UnityWorldSpaceLightDir(i.world_pos));
                float3 world_normal = normalize(i.world_normal);
                //float3 half_dir = normalize(i.world_normal + light_dir);
                diffuse = diffuse * (0.5 + 0.5 * saturate(dot(world_normal,light_dir)));
                //diffuse = diffuse * saturate(dot(world_normal,light_dir));
                
                return diffuse;
            }
            ENDCG
        }
    }
}
