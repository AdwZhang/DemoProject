Shader "Unlit/DepthImage"
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
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 scr_pos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.scr_pos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_CameraDepthTexture, i.scr_pos);
                //float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.scr_pos);
                float depth = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scr_pos)));
	            float linear01Depth = Linear01Depth(depth);
                return linear01Depth;
            }
            ENDCG
        }
    }
}
