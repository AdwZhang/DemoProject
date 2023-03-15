// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GlobalFog"
{
	Properties
	{
		_FogColor("Fog Color", Color) = (0,0,0,0)
		_SunColor("Sun Color", Color) = (0,0,0,0)
		_FogHeightStart("Fog Height Start", Float) = 0
		_FogHeightEnd("Fog Height End", Float) = 700
		_SunFogRange("Sun Fog Range", Float) = 10
		_SunFogIntensity("Sun Fog Intensity", Float) = 1
		_FogDistanceStart("Fog Distance Start", Float) = 0
		_FogDistanceEnd("Fog Distance End", Float) = 700
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 viewDir;
			float3 worldPos;
			float4 screenPos;
		};

		uniform float4 _FogColor;
		uniform float4 _SunColor;
		uniform float _SunFogRange;
		uniform float _SunFogIntensity;
		uniform float _FogDistanceEnd;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _FogDistanceStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g7( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult18 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult31 = clamp( pow( (dotResult18*0.5 + 0.5) , _SunFogRange ) , 0.0 , 1.0 );
			float clampResult13 = clamp( ( clampResult31 * _SunFogIntensity ) , 0.0 , 1.0 );
			float fogSun14 = clampResult13;
			float4 lerpResult7 = lerp( _FogColor , _SunColor , fogSun14);
			o.Emission = lerpResult7.rgb;
			float temp_output_9_0_g5 = _FogDistanceEnd;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g8 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g8 = UnStereo( UV22_g8 );
			float2 break64_g7 = localUnStereo22_g8;
			float clampDepth69_g7 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g7 = ( 1.0 - clampDepth69_g7 );
			#else
				float staticSwitch38_g7 = clampDepth69_g7;
			#endif
			float3 appendResult39_g7 = (float3(break64_g7.x , break64_g7.y , staticSwitch38_g7));
			float4 appendResult42_g7 = (float4((appendResult39_g7*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g7 = mul( unity_CameraInvProjection, appendResult42_g7 );
			float3 temp_output_46_0_g7 = ( (temp_output_43_0_g7).xyz / (temp_output_43_0_g7).w );
			float3 In72_g7 = temp_output_46_0_g7;
			float3 localInvertDepthDir72_g7 = InvertDepthDir72_g7( In72_g7 );
			float4 appendResult49_g7 = (float4(localInvertDepthDir72_g7 , 1.0));
			float3 worldPos47 = (mul( unity_CameraToWorld, appendResult49_g7 )).xyz;
			float clampResult6_g5 = clamp( ( ( temp_output_9_0_g5 - distance( worldPos47 , _WorldSpaceCameraPos ) ) / ( temp_output_9_0_g5 - _FogDistanceStart ) ) , 0.0 , 1.0 );
			float fogDistance37 = ( 1.0 - clampResult6_g5 );
			float temp_output_9_0_g4 = _FogHeightEnd;
			float clampResult6_g4 = clamp( ( ( temp_output_9_0_g4 - (worldPos47).y ) / ( temp_output_9_0_g4 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float fogHeight36 = ( 1.0 - ( 1.0 - clampResult6_g4 ) );
			float TotalFog41 = ( fogDistance37 * fogHeight36 );
			o.Alpha = TotalFog41;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1920;-1;1920;1012;1661.494;291.7885;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;10;-2609.656,1643.012;Inherit;False;1773.223;482.8016;Fog Sun;12;35;33;31;29;24;20;18;17;16;15;14;13;;1,0.2028302,0.2028302,1;0;0
Node;AmplifyShaderEditor.FunctionNode;46;-3736.344,1075.529;Inherit;False;Reconstruct World Position From Depth;-1;;7;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;15;-2559.656,1693.012;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;52;-3384.344,1072.529;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;17;-2430.353,1860.812;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;16;-2322.555,1697.411;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-3209.344,1071.529;Inherit;False;worldPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;11;-2611.141,983.5546;Inherit;False;1109.711;575.0862;Fog Height;7;36;32;28;23;19;54;55;;0.6556604,0.8893502,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2166.555,1749.411;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-2579.196,1408.582;Inherit;False;47;worldPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;12;-2626.183,274.4084;Inherit;False;1221.476;599;Fog Distance;7;37;34;30;27;26;22;48;;0.6556604,0.8893502,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;22;-2560.183,681.4084;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;23;-2443.146,1068.555;Inherit;False;Property;_FogHeightStart;Fog Height Start;2;0;Create;True;0;0;0;False;0;False;0;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2509.344,444.5291;Inherit;False;47;worldPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2027.828,1924.075;Inherit;False;Property;_SunFogRange;Sun Fog Range;4;0;Create;True;0;0;0;False;0;False;10;55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;20;-1990.504,1749.114;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2432.146,1232.555;Inherit;False;Property;_FogHeightEnd;Fog Height End;3;0;Create;True;0;0;0;False;0;False;700;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;55;-2402.196,1408.582;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;30;-2155.187,596.4084;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;-1743.366,1793.498;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;28;-2215.171,1212.053;Inherit;False;FogLinear;-1;;4;bc245833e05c4614bb25099f04bdfe89;0;3;11;FLOAT;0;False;9;FLOAT;700;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2167.188,324.4084;Inherit;False;Property;_FogDistanceStart;Fog Distance Start;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2180.188,471.4082;Inherit;False;Property;_FogDistanceEnd;Fog Distance End;7;0;Create;True;0;0;0;False;0;False;700;700;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;31;-1562.431,1794.813;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1602.431,2009.814;Inherit;False;Property;_SunFogIntensity;Sun Fog Intensity;5;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1993.683,1211.246;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;34;-1939.214,467.9067;Inherit;False;FogLinear;-1;;5;bc245833e05c4614bb25099f04bdfe89;0;3;11;FLOAT;0;False;9;FLOAT;700;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1805.801,1206.097;Inherit;False;fogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1370.431,1863.814;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1647.706,463.9525;Inherit;False;fogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;13;-1216.333,1864.462;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1226.325,735.9156;Inherit;False;37;fogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1225.325,852.9148;Inherit;False;36;fogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-1060.431,1859.814;Inherit;False;fogSun;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-925.9307,769.3128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1041.346,-238.9027;Inherit;False;Property;_FogColor;Fog Color;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8058473,0.8584906,0.8584906,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-1036.273,-7.949615;Inherit;False;Property;_SunColor;Sun Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5958981,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;3;-1023.533,235.5302;Inherit;False;14;fogSun;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-759.3247,764.9149;Inherit;False;TotalFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;7;-667.4142,-72.66513;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;6;-546.7643,219.7418;Inherit;False;41;TotalFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;GlobalFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;46;0
WireConnection;16;0;15;0
WireConnection;47;0;52;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;20;0;18;0
WireConnection;55;0;54;0
WireConnection;30;0;48;0
WireConnection;30;1;22;0
WireConnection;29;0;20;0
WireConnection;29;1;24;0
WireConnection;28;11;23;0
WireConnection;28;9;19;0
WireConnection;28;10;55;0
WireConnection;31;0;29;0
WireConnection;32;0;28;0
WireConnection;34;11;26;0
WireConnection;34;9;27;0
WireConnection;34;10;30;0
WireConnection;36;0;32;0
WireConnection;35;0;31;0
WireConnection;35;1;33;0
WireConnection;37;0;34;0
WireConnection;13;0;35;0
WireConnection;14;0;13;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;41;0;40;0
WireConnection;7;0;2;0
WireConnection;7;1;5;0
WireConnection;7;2;3;0
WireConnection;0;2;7;0
WireConnection;0;9;6;0
ASEEND*/
//CHKSM=496DCC2BCAA0BE9EFDFD2AF5EE0AB8E858FD79C3