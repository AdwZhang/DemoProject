Shader "Unlit/MatCap_Code"
{
    Properties
    {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _Matcap ("Matcap", 2D) = "white" {}
        _MatcapIntensity ("MatcapIntensity",float) = 5
        _MatcapAdd ("MatcapAdd", 2D) = "white" {}
        _MatcapAddIntensity ("MatcapAddIntensity",float) = 0.5
        _Ramp ("Ramp", 2D) = "white" {}
        _RampIntensity ("RampIntensity",float) = 0.5
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
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
            };

            sampler2D _Diffuse;
            float4 _Diffuse_ST;
            sampler2D _Matcap;
            float _MatcapIntensity;
            sampler2D _MatcapAdd;
            float _MatcapAddIntensity;
            sampler2D _Ramp;
            float _RampIntensity;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _Diffuse);
                o.normal_world = mul(v.normal,(float3x3)unity_WorldToObject);
                o.pos_world = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal_world = normalize(i.normal_world);

                half3 normal_viewspace = mul(unity_MatrixV,normal_world);
                half2 uv_matcap = (normal_viewspace.xy + float2(1.0,1.0) )* 0.5;
                float4 matcap_col = tex2D(_Matcap,uv_matcap) * _MatcapIntensity;
                float4 matcap_add_col = tex2D(_MatcapAdd,uv_matcap) * _MatcapAddIntensity;
                
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half NdotV = dot(normal_world,view_dir);
                half fresnel = 1 - saturate(NdotV);
                half2 ramp_uv = half2(fresnel,0.5);
                float4 ramp_col = tex2D(_Ramp,ramp_uv);

                float4 diffuse_col = tex2D(_Diffuse,i.uv);
                
                return matcap_add_col + matcap_col * ramp_col * diffuse_col;
            }
            ENDCG
        }
    }
}
