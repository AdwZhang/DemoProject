Shader "Custom/StylizedWater"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _ShoreLineThreshold("ShoreLine threshold",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}      //--
        Blend SrcAlpha OneMinusSrcAlpha     //--
        ZWrite off      //--
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:premul

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float3 viewDir;
            float4 screenPos;
        };

        half _Glossiness;
        fixed4 _Color;

        sampler2D _CameraDepthTexture;
        float _ShoreLineThreshold;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float depth = tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(IN.screenPos));
            depth = LinearEyeDepth(depth);
            // Albedo comes from a texture tinted by color
            fixed4 c =  _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
