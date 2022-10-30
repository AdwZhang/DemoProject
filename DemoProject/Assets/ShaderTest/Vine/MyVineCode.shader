Shader "Unlit/MyVineCode"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Grow ("Grow", Range(0,1)) = 1.0
        _EndLength("EndLength", Range(0,1)) = 1.0
        _Expand("Expand",Float) = 0.0
        _ClipLength("ClipLength", Range(0,1)) = 1.0
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Grow;
            float _EndLength;
            float _Expand;
            float _ClipLength;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float growFactor = growFactor = smoothstep(_Grow - _EndLength,_Grow,o.uv.y);
                
                v.vertex.xyz = v.vertex.xyz + v.normal * growFactor * _Expand * 0.01;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(_Grow - i.uv.y - _ClipLength);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
