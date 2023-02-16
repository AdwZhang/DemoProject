Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle(DECODE_HDR_ON)] _Decode_Hdr("Decode_Hdr", Float) = 1 
    }
    SubShader
    {
        Tags { "RenderType"="Background" }

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_HDR;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                #if UNITY_REVERSED_Z
                    o.pos.z = o.pos.w * 0.00001f;
                #else
                    o.pos.z = o.pos.w * 0.99999f;
                #endif
                //o.pos.x = o.pos.w * 0.000001f;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);
                #ifdef DECODE_HDR_ON
                    half3 col_hdr = DecodeHDR(col,_MainTex_HDR);
                    return half4(col_hdr,1.0);
                #else
                    return col;
                #endif
            }
            ENDCG
        }
    }
}
