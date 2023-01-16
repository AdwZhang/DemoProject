Shader "Dissolution/FlagCode"
{
    Properties
    {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _DissolveTex ("DissolveTex", 2D) = "white" {}
        _EdgeColor("EdgeColor", Color) = (0,0,0,0)
        _ChangeAmount ("ChangeAmount",Range(0,1)) = 0.0
        _EdgeWidth ("EdgeWidth",Range(0,2)) = 0.0
        _CutOff("CutOff", Float) = 0.5
        _EdgeIntensity("EdgeIntensity", Range(1,10)) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "IgnoreProjector" = "True" "RenderType"="TransparentCutout" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
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

            sampler2D _Diffuse;
            float4 _Diffuse_ST;
            
            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;

            fixed4 _EdgeColor;
            fixed _ChangeAmount;
            fixed _EdgeWidth;
            fixed _CutOff;
            fixed _EdgeIntensity;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Diffuse);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_Diffuse, i.uv);

                fixed dissolveValue = tex2D(_DissolveTex, i.uv).r;

                fixed changeValue;

                changeValue = _ChangeAmount;

                changeValue = frac(_Time.y * 0.25);
                
                changeValue = changeValue * 2 - 1;
                
                fixed change = dissolveValue - changeValue;
                clip(step(_CutOff, col.a * change) - 0.5);

                fixed edge_alpha = distance(saturate(change), _CutOff);
                edge_alpha = edge_alpha / _EdgeWidth; 
                edge_alpha = 1 - edge_alpha;
                _EdgeColor = _EdgeColor * _EdgeIntensity;
                col = lerp(col, _EdgeColor, saturate(edge_alpha));              
                
                return col;
            }
            ENDCG
        }
    }
}
