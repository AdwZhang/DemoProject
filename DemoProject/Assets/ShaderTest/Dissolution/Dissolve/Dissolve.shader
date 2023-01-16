Shader "TextureShader/Dissolve"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _CutMaskTex ("Cut Mask", 2D) = "white" {}
        _CutAmount ("Cut Amount", range(0,1)) = 0.5 
        
        _LineWidth ("Line Width", float) = 0.1
        _LineColor ("Line Color", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" }

        Pass
        {
            Cull OFF
            
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CutMaskTex;
            float _CutAmount;
            float _LineWidth;
            fixed4 _LineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_CutMaskTex,i.uv);
                float minus = mask.r - _CutAmount;
                clip(minus);

                fixed4 lineC = fixed4(0,0,0,0);
                float t = 0;
                float m = 1/_LineWidth;
                if(minus < _LineWidth)
                {
                    t = minus * m;
                    lineC = lerp(0,_LineColor,t);
                }
                fixed4 finalColor = lerp(col,lineC,t);
                return finalColor;
            }
            ENDCG
        }
    }
}
