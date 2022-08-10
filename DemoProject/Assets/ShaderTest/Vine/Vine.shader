// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vine"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0
		_Expand("Expand", Float) = 0
		_Grow("Grow", Range( -2 , 2)) = 0
		_GrowMin("GrowMin", Range( 0 , 1)) = 0
		_GrowMax("GrowMax", Range( 0 , 1.5)) = 0
		_EndMin("EndMin", Range( 0 , 1)) = 0
		_EndMax("EndMax", Range( 0 , 1.5)) = 0
		_Diffuse("Diffuse", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_Roughness("Roughness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _GrowMin;
		uniform float _GrowMax;
		uniform float _Grow;
		uniform float _EndMin;
		uniform float _EndMax;
		uniform float _Expand;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform sampler2D _Roughness;
		uniform float4 _Roughness_ST;
		uniform float _Cutoff = 0;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_6_0 = ( v.texcoord.xy.y - _Grow );
			float smoothstepResult9 = smoothstep( _GrowMin , _GrowMax , temp_output_6_0);
			float smoothstepResult15 = smoothstep( _EndMin , _EndMax , v.texcoord.xy.y);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( max( smoothstepResult9 , smoothstepResult15 ) * ase_vertexNormal * _Expand * 0.1 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = tex2D( _Normal, uv_Normal ).rgb;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			o.Albedo = tex2D( _Diffuse, uv_Diffuse ).rgb;
			float2 uv_Roughness = i.uv_texcoord * _Roughness_ST.xy + _Roughness_ST.zw;
			o.Smoothness = ( 1.0 - tex2D( _Roughness, uv_Roughness ) ).r;
			o.Alpha = 1;
			float temp_output_6_0 = ( i.uv_texcoord.y - _Grow );
			clip( ( 1.0 - temp_output_6_0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1920;0;1920;1019;2170.632;-30.06219;1.3;True;False
Node;AmplifyShaderEditor.RangedFloatNode;7;-1615.462,396.303;Inherit;False;Property;_Grow;Grow;2;0;Create;True;0;0;0;False;0;False;0;-0.03;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1572.462,249.303;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-1395.139,897.6991;Inherit;False;Property;_EndMin;EndMin;5;0;Create;True;0;0;0;False;0;False;0;0.549;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1376.359,1003.052;Inherit;False;Property;_EndMax;EndMax;6;0;Create;True;0;0;0;False;0;False;0;1.272;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1386.638,759.2991;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-1446.462,589.3029;Inherit;False;Property;_GrowMax;GrowMax;4;0;Create;True;0;0;0;False;0;False;0;1.23;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1448.462,491.303;Inherit;False;Property;_GrowMin;GrowMin;3;0;Create;True;0;0;0;False;0;False;0;0.65;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-1333.462,373.303;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;9;-1105.462,437.303;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;15;-1041.359,703.0518;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;1;-824.3138,825.3044;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;16;-829.3595,608.052;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-802.3139,992.3044;Inherit;False;Property;_Expand;Expand;1;0;Create;True;0;0;0;False;0;False;0;-0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-718.3138,205.2372;Inherit;True;Property;_Roughness;Roughness;9;0;Create;True;0;0;0;False;0;False;-1;None;6ef1d220957b1dc4db681e82ba675cc2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-800.4622,1104.303;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-368.3138,212.2372;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;17;-723.6596,-237.8399;Inherit;True;Property;_Diffuse;Diffuse;7;0;Create;True;0;0;0;False;0;False;-1;None;79e4b2b14999cef4eae6601d3e35c286;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;8;-1157.462,344.303;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-546.4621,837.3029;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;18;-720.3138,-8.762787;Inherit;True;Property;_Normal;Normal;8;0;Create;True;0;0;0;False;0;False;-1;None;0325b4f4906da984cb7370db770933a5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-108,166;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Vine;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;5;2
WireConnection;6;1;7;0
WireConnection;9;0;6;0
WireConnection;9;1;10;0
WireConnection;9;2;11;0
WireConnection;15;0;12;2
WireConnection;15;1;13;0
WireConnection;15;2;14;0
WireConnection;16;0;9;0
WireConnection;16;1;15;0
WireConnection;20;0;19;0
WireConnection;8;0;6;0
WireConnection;4;0;16;0
WireConnection;4;1;1;0
WireConnection;4;2;2;0
WireConnection;4;3;3;0
WireConnection;0;0;17;0
WireConnection;0;1;18;0
WireConnection;0;4;20;0
WireConnection;0;10;8;0
WireConnection;0;11;4;0
ASEEND*/
//CHKSM=943C21730D2B5F6337F294A9DA85B2DE2897037C