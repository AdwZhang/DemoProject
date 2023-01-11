Shader "Dissolution/FlagCode"
{
    Properties
    {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _DissolveTex ("DissolveTex", 2D) = "white" {}
        
        _ChangeAmount ("ChangeAmount",Range(0,1)) = 0.0
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

            fixed _ChangeAmount;
            
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
                clip(col.a - 0.5);

                fixed dissolveValue = tex2D(_DissolveTex, i.uv).r;

                _ChangeAmount = _ChangeAmount * 2 - 1;
                
                fixed change = dissolveValue - _ChangeAmount;
                
                return col;
            }
            ENDCG
        }
    }
}
