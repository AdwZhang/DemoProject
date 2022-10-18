Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screen_pos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screen_pos = o.vertex;
                //o.screen_pos = ComputeScreenPos(o.vertex);    //直接处理
                o.screen_pos.y = o.screen_pos.y * _ProjectionParams.x;  // _ProjectionParams.x 平台参数，处理跨平台引起的坐标系差异问题
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 screen_uv = i.screen_pos.xy / (i.screen_pos.w + 0.000001);     //透视除法  [-1,1]
                screen_uv = (screen_uv + 1.0) * 0.5;  // [0,1]
                // sample the texture
                fixed4 col = tex2D(_MainTex, screen_uv);

                return col;
            }
            ENDCG
        }
    }
}
