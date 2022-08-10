Shader "Unlit/Vine_Code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Grow ("Grow",Range(-2,2)) = 0.0
        _GrowMin ("GrowMin",Range(0,1)) = 0.0
        _GrowMax ("GrowMax",Range(0,1.5)) = 0.0
        _EndMin ("EndMin",Range(0,1)) = 0.0
        _EndMax ("EndMax",Range(0,1.5)) = 0.0
        _Expand ("Expand",float) = 0.0
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Grow;
            float _GrowMin;
            float _GrowMax;
            float _EndMin;
            float _EndMax;
            float _Expand;

            v2f vert (appdata v)
            {
                v2f o;
                float grow_sub = v.texcoord.y - _Grow;
                float grow_factor = max(smoothstep(_GrowMin,_GrowMax,grow_sub),smoothstep(_EndMin,_EndMax,v.texcoord.y));

                float3 offset = grow_factor * v.normal * _Expand * 0.01;
                float3 vertex = v.vertex + offset;
                
                o.vertex = UnityObjectToClipPos(vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(1-(i.uv.y - _Grow));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
