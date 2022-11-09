Shader "Unlit/CubeMap"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _CubeMap ("Cube Map", Cube) = "white" {}
        _BumpMap ("Normal", 2D) = "Bump" {}
        _AOMap ("AO Map", 2D) = "white" {}
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
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            /*sampler2D _MainTex;
            float4 _MainTex_ST;*/

            samplerCUBE _CubeMap;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _AOMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _BumpMap);
                //o.uv = v.texcoord;
                
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex);
                
                float3 normal_world = UnityObjectToWorldDir(v.normal);
                float3 tangent_world = UnityObjectToWorldDir(v.tangent);
                float3 binormal_world = cross(normal_world,tangent_world) * v.tangent.w;

                o.TtoW0 = float4(tangent_world.x,binormal_world.x,normal_world.x,pos_world.x);
                o.TtoW1 = float4(tangent_world.y,binormal_world.y,normal_world.y,pos_world.y);
                o.TtoW2 = float4(tangent_world.z,binormal_world.z,normal_world.z,pos_world.z);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);

                float3x3 TBN = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
                float3 pos_world = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

                float3 normal_dir = UnpackNormal(tex2D(_BumpMap, i.uv));
                normal_dir = normalize(mul(TBN, normal_dir));

                float AO = tex2D(_AOMap, i.uv).r;
                
                float3 view_dir = normalize(UnityWorldSpaceViewDir(pos_world));
                float3 reflect_dir = reflect(-view_dir,normal_dir);

                float4 color_cubemap = texCUBE(_CubeMap,reflect_dir);
                float4 final_color = color_cubemap * AO;
                return final_color;
            }
            ENDCG
        }
    }
}
