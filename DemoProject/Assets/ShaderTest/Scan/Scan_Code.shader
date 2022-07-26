Shader "Unlit/Scan_Code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimMin("RimMin",Range(-1,1)) = 0.0
        _RimMax("RimMax",Range(-1,2)) = 1.0
        _InnerColor("Inner Color",Color) = (0.0,0.0,0.0,0.0)
        _RimColor("Rim Color",Color) = (1.0,1.0,1.0,1.0)
        _RimIntensity("Rim Intensity",Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Tranparent"}
        LOD 100

        Pass
		{
			ColorMask 0
			ZWrite On
		}
        
        Pass
        {
            ZWrite Off
            Blend SrcAlpha one
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog

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
                float3 pos_world : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RimMin;
            float _RimMax;
            float4 _InnerColor;
            float4 _RimColor;
            float _RimIntensity; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                
                o.pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_world = mul(v.normal,(float3x3)unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half3 normal_world = normalize(i.normal_world);
                half3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half3 NdotV = saturate(dot(normal_world,view_world));
                half fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_RimMin,_RimMax,fresnel);
                half emiss = tex2D(_MainTex, i.uv).r;
                emiss = pow(emiss,5.0);
                half final_fresnel = saturate(emiss + fresnel);
                half3 final_rim_color = lerp(_InnerColor.xyz,_RimColor.xyz * _RimIntensity,final_fresnel);
                return float4(final_rim_color,final_fresnel);
            }
            ENDCG
        }
    }
}
