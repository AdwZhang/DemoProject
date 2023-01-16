// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flag"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.7200947
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 2
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_EdgeIntensity("EdgeIntensity", Float) = 1
		[Toggle(_ISAUTO_ON)] _IsAuto("IsAuto", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _ISAUTO_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeIntensity;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _EdgeWidth;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float4 tex2DNode1 = tex2D( _TextureSample0, uv_TextureSample0 );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime23 = _Time.y * 0.2;
			#ifdef _ISAUTO_ON
				float staticSwitch25 = frac( mulTime23 );
			#else
				float staticSwitch25 = _ChangeAmount;
			#endif
			float temp_output_3_0 = ( tex2D( _Gradient, uv_Gradient ).r - (-1.0 + (staticSwitch25 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) );
			float clampResult19 = clamp( ( 1.0 - ( distance( temp_output_3_0 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult17 = lerp( tex2DNode1 , ( _EdgeColor * tex2DNode1 * _EdgeIntensity ) , clampResult19);
			o.Emission = lerpResult17.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode1.a * step( 0.5 , temp_output_3_0 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1920;0;1920;1019;1748.701;-234.3718;1;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;23;-1457.701,920.3718;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;24;-1220.701,921.3718;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1450.098,669.3453;Inherit;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;0;False;0;False;0.7200947;0.113;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;25;-1136.701,714.3718;Inherit;False;Property;_IsAuto;IsAuto;7;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1017.687,413.4261;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;870cdefd93bc92f48a0f98ff2d53984f;5ffd3652ed2677743a7832b85d12b3ae;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;5;-899.7371,718.4114;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;3;-636.4077,583.7913;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-618.9789,837.7028;Inherit;False;Constant;_xxxx;xxxx;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;8;-218.1529,657.0856;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-180.0667,925.4659;Inherit;False;Property;_EdgeWidth;EdgeWidth;4;0;Create;True;0;0;0;False;0;False;2;0.1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;133.3708,655.631;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;395.6059,656.212;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;45.81666,314.4839;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;6;0;Create;True;0;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;29.24753,135.5608;Inherit;False;Property;_EdgeColor;EdgeColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9921569,0.5940148,0.06274512,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-461.6669,31.16667;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;928fe281803e9ff419abc05609e67d2e;928fe281803e9ff419abc05609e67d2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;287.5156,133.9124;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;14;-376.2555,412.7809;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;19;576.5234,657.8587;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-123.5868,382.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;553.9976,38.22369;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;905.898,-9.310107;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Flag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;24;0;23;0
WireConnection;25;1;6;0
WireConnection;25;0;24;0
WireConnection;5;0;25;0
WireConnection;3;0;2;1
WireConnection;3;1;5;0
WireConnection;8;0;3;0
WireConnection;8;1;9;0
WireConnection;13;0;8;0
WireConnection;13;1;12;0
WireConnection;18;0;13;0
WireConnection;20;0;15;0
WireConnection;20;1;1;0
WireConnection;20;2;21;0
WireConnection;14;1;3;0
WireConnection;19;0;18;0
WireConnection;7;0;1;4
WireConnection;7;1;14;0
WireConnection;17;0;1;0
WireConnection;17;1;20;0
WireConnection;17;2;19;0
WireConnection;0;2;17;0
WireConnection;0;10;7;0
ASEEND*/
//CHKSM=81E10EBB4603FA5156AA5EE199271FACA210BEB5