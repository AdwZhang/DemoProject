// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Terrian"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_BaseColor("BaseColor", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FogHeightStart("Fog Height Start", Float) = 0
		_FogHeightEnd("Fog Height End", Float) = 700
		_FogColor("FogColor", Color) = (0,0,0,0)
		_SunFogRange("Sun Fog Range", Float) = 10
		_SunFogIntensity("Sun Fog Intensity", Float) = 1
		_SunColor("SunColor", Color) = (0,0,0,0)
		_FogDistanceStart("Fog Distance Start", Float) = 0
		_FogDistanceEnd("Fog Distance End", Float) = 700
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _Smoothness;
		uniform float4 _BaseColor;
		uniform float4 _FogColor;
		uniform float4 _SunColor;
		uniform float _SunFogRange;
		uniform float _SunFogIntensity;
		uniform float _FogDistanceEnd;
		uniform float _FogDistanceStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldNormal = i.worldNormal;
			Unity_GlossyEnvironmentData g3 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular3 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g3 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult48 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult53 = clamp( pow( (dotResult48*0.5 + 0.5) , _SunFogRange ) , 0.0 , 1.0 );
			float clampResult62 = clamp( ( clampResult53 * _SunFogIntensity ) , 0.0 , 1.0 );
			float fogSun57 = clampResult62;
			float4 lerpResult60 = lerp( _FogColor , _SunColor , fogSun57);
			float temp_output_9_0_g5 = _FogDistanceEnd;
			float clampResult6_g5 = clamp( ( ( temp_output_9_0_g5 - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( temp_output_9_0_g5 - _FogDistanceStart ) ) , 0.0 , 1.0 );
			float fogDistance23 = ( 1.0 - clampResult6_g5 );
			float temp_output_9_0_g4 = _FogHeightEnd;
			float clampResult6_g4 = clamp( ( ( temp_output_9_0_g4 - ase_worldPos.y ) / ( temp_output_9_0_g4 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float fogHeight35 = ( 1.0 - ( 1.0 - clampResult6_g4 ) );
			float TotalFog41 = ( fogDistance23 * fogHeight35 );
			float4 lerpResult17 = lerp( ( float4( indirectSpecular3 , 0.0 ) * _BaseColor ) , lerpResult60 , TotalFog41);
			c.rgb = lerpResult17.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				Input customInputData;
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
1920;0;1920;1011;1813.756;229.5654;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;63;-2963.552,1907.502;Inherit;False;1773.223;482.8016;Fog Sun;12;50;52;49;48;46;47;51;55;62;57;53;54;;1,0.2028302,0.2028302,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;46;-2913.552,1957.502;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;47;-2784.249,2125.302;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;49;-2676.451,1961.901;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2615.739,1219.804;Inherit;False;1109.711;575.0862;Fog Height;6;35;42;34;29;31;32;;0.6556604,0.8893502,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2630.781,510.6577;Inherit;False;1221.476;599;Fog Distance;7;7;5;6;23;8;9;27;;0.6556604,0.8893502,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;48;-2520.451,2013.901;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2381.723,2188.565;Inherit;False;Property;_SunFogRange;Sun Fog Range;10;0;Create;True;0;0;0;False;0;False;10;55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;50;-2344.4,2013.604;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2436.744,1468.804;Inherit;False;Property;_FogHeightEnd;Fog Height End;8;0;Create;True;0;0;0;False;0;False;700;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-2568.739,1608.804;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;31;-2447.744,1304.804;Inherit;False;Property;_FogHeightStart;Fog Height Start;7;0;Create;True;0;0;0;False;0;False;0;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-2490.781,702.6573;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;5;-2564.781,917.6577;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;34;-2219.769,1448.302;Inherit;False;FogLinear;-1;;4;bc245833e05c4614bb25099f04bdfe89;0;3;11;FLOAT;0;False;9;FLOAT;700;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;51;-2097.264,2057.988;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;7;-2159.785,832.6577;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2171.786,560.6577;Inherit;False;Property;_FogDistanceStart;Fog Distance Start;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2184.786,707.6575;Inherit;False;Property;_FogDistanceEnd;Fog Distance End;14;0;Create;True;0;0;0;False;0;False;700;700;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1956.329,2274.304;Inherit;False;Property;_SunFogIntensity;Sun Fog Intensity;11;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;27;-1943.812,704.156;Inherit;False;FogLinear;-1;;5;bc245833e05c4614bb25099f04bdfe89;0;3;11;FLOAT;0;False;9;FLOAT;700;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;53;-1916.329,2059.303;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-1998.281,1447.495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1810.399,1442.346;Inherit;False;fogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1724.329,2128.304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1652.305,700.2017;Inherit;False;fogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1194.442,999.1099;Inherit;False;23;fogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-1193.442,1116.11;Inherit;False;35;fogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;62;-1570.231,2128.952;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1414.329,2124.304;Inherit;False;fogSun;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-894.0482,1032.508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1564.284,38.73209;Inherit;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-727.4421,1028.11;Inherit;False;TotalFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;3;-1198.284,19.7321;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;45;-949.8865,304.5572;Inherit;False;Property;_FogColor;FogColor;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8058473,0.8584906,0.8584906,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;59;-1226.813,452.5103;Inherit;False;Property;_SunColor;SunColor;12;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5958981,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-964.0737,530.9901;Inherit;False;57;fogSun;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-1183.284,194.732;Inherit;False;Property;_BaseColor;BaseColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4771865,0.9528302,0.2831524,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-519.3047,519.2017;Inherit;False;41;TotalFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-668.9546,373.7948;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-874.2825,123.732;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1227.305,805.2017;Inherit;False;41;TotalFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-319.3176,276.0944;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;18;-862.8622,781.6469;Inherit;True;Property;_FogGradientColor;FogGradientColor;15;0;Create;True;0;0;0;False;0;False;-1;None;3415674866edfd947b0ee62e931e0344;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;20;-1039.309,809.5202;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-7.800001,36.39999;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Terrian;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;46;0
WireConnection;48;0;49;0
WireConnection;48;1;47;0
WireConnection;50;0;48;0
WireConnection;34;11;31;0
WireConnection;34;9;32;0
WireConnection;34;10;29;2
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;27;11;9;0
WireConnection;27;9;8;0
WireConnection;27;10;7;0
WireConnection;53;0;51;0
WireConnection;42;0;34;0
WireConnection;35;0;42;0
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;23;0;27;0
WireConnection;62;0;54;0
WireConnection;57;0;62;0
WireConnection;38;0;39;0
WireConnection;38;1;40;0
WireConnection;41;0;38;0
WireConnection;3;1;2;0
WireConnection;60;0;45;0
WireConnection;60;1;59;0
WireConnection;60;2;58;0
WireConnection;4;0;3;0
WireConnection;4;1;1;0
WireConnection;17;0;4;0
WireConnection;17;1;60;0
WireConnection;17;2;26;0
WireConnection;18;1;20;0
WireConnection;20;0;25;0
WireConnection;0;13;17;0
ASEEND*/
//CHKSM=696AA887E08F833FD1ADAB1ECEBF7B719E8178B5