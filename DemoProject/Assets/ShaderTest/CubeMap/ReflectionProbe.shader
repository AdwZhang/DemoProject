Shader "ReflectionProbe"
{
    Properties
    {
        _BumpMap ("Normal", 2D) = "Bump" {}
        _AOMap ("AO Map", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,1,1,1)
        _Expose ("Expose", Float) = 1.0
        _Rotate ("Rotate", Range(0,360)) = 0.0
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
            float4 _CubeMap_HDR;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _AOMap;
            float4 _Tint;
            float _Expose;
            float _Rotate;

            float3 rotateDir(float degree, float3 dir)
            {
                float rad = degree * UNITY_PI / 180;
                float2x2 rotateMatrix = float2x2( cos(rad), -sin(rad),
                                                  sin(rad), cos(rad));
                dir.xz = mul(rotateMatrix,dir.xz);
                return dir;
            }
            
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

                float ao = tex2D(_AOMap, i.uv).r;
                
                float3 view_dir = normalize(UnityWorldSpaceViewDir(pos_world));
                float3 reflect_dir = reflect(-view_dir,normal_dir);

                reflect_dir = rotateDir(_Rotate,reflect_dir);
                
                float4 env_color = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflect_dir);
                float3 env_hdr_color = DecodeHDR(env_color,unity_SpecCube0_HDR);
                float3 final_color = env_hdr_color * ao * _Tint * _Expose ;
                return fixed4(final_color,1.0);
            }
            ENDCG
        }
    }
}
