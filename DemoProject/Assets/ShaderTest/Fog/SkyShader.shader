// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SkyShader"
{
	Properties
	{
		_SkyHDR("SkyHDR", 2D) = "white" {}
		_FogHeightStart("Fog Height Start", Range( -1 , 1)) = 0
		_FogHeightEnd("Fog Height End", Range( -1 , 1)) = 0
		_FogColor("FogColor", Color) = (0,0,0,0)
		_SunFogRange("Sun Fog Range", Float) = 10
		_SunFogIntensity("Sun Fog Intensity", Float) = 1
		_SunColor("SunColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Background+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldPos;
		};

		uniform sampler2D _SkyHDR;
		uniform float4 _SkyHDR_ST;
		uniform float4 _FogColor;
		uniform float4 _SunColor;
		uniform float _SunFogRange;
		uniform float _SunFogIntensity;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_SkyHDR = i.uv_texcoord * _SkyHDR_ST.xy + _SkyHDR_ST.zw;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult42 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult48 = clamp( pow( (dotResult42*0.5 + 0.5) , _SunFogRange ) , 0.0 , 1.0 );
			float clampResult47 = clamp( ( clampResult48 * _SunFogIntensity ) , 0.0 , 1.0 );
			float fogSun39 = clampResult47;
			float4 lerpResult21 = lerp( _FogColor , _SunColor , fogSun39);
			float temp_output_9_0_g4 = _FogHeightEnd;
			float3 objToWorld31 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 normalizeResult33 = normalize( ( ase_worldPos - objToWorld31 ) );
			float clampResult6_g4 = clamp( ( ( temp_output_9_0_g4 - (normalizeResult33).y ) / ( temp_output_9_0_g4 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float fogHorizon25 = ( 1.0 - ( 1.0 - clampResult6_g4 ) );
			float4 lerpResult23 = lerp( tex2D( _SkyHDR, uv_SkyHDR ) , lerpResult21 , fogHorizon25);
			o.Emission = lerpResult23.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
1920;0;1920;1011;2091.539;-908.8471;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;37;-1608.475,1896.853;Inherit;False;1773.223;482.8016;Fog Sun;12;49;48;47;46;45;44;43;42;41;40;39;38;;1,0.2028302,0.2028302,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;43;-1558.475,1946.853;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;44;-1429.172,2114.653;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;38;-1321.374,1951.252;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;24;-1591.475,1057.392;Inherit;False;1178.711;716.0862;Fog Horizon;8;31;27;28;25;30;29;26;36;;0.6556604,0.8893502,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;42;-1165.374,2003.252;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;27;-1501.475,1426.392;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;40;-989.3229,2002.955;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;31;-1522.75,1600.332;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;41;-1026.646,2177.916;Inherit;False;Property;_SunFogRange;Sun Fog Range;5;0;Create;True;0;0;0;False;0;False;10;55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;45;-742.187,2047.339;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-1234.75,1560.332;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-601.252,2263.655;Inherit;False;Property;_SunFogIntensity;Sun Fog Intensity;6;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;33;-1060.75,1592.332;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;48;-561.2521,2048.653;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1510.479,1296.392;Inherit;False;Property;_FogHeightEnd;Fog Height End;3;0;Create;True;0;0;0;False;0;False;0;500;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-369.2522,2117.655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;36;-902.75,1590.332;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1464.479,1138.392;Inherit;False;Property;_FogHeightStart;Fog Height Start;2;0;Create;True;0;0;0;False;0;False;0;-50;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;29;-1126.505,1285.89;Inherit;False;FogLinear;-1;;4;bc245833e05c4614bb25099f04bdfe89;0;3;11;FLOAT;0;False;9;FLOAT;700;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-215.1541,2118.303;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-905.0166,1285.083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-59.25205,2113.655;Inherit;False;fogSun;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1490.02,-138.6351;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-718.1346,1278.934;Inherit;False;fogHorizon;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-996.949,251.6382;Inherit;False;Property;_FogColor;FogColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8058473,0.8584906,0.8584906,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;-931.2458,549.9471;Inherit;False;39;fogSun;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-1201.985,438.4673;Inherit;False;Property;_SunColor;SunColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5958981,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1198.02,-163.6351;Inherit;True;Property;_SkyHDR;SkyHDR;1;0;Create;True;0;0;0;False;0;False;-1;None;4f269ec0f6d95564b93e23a38a803d61;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;21;-644.1267,359.7518;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-688.033,725.4124;Inherit;False;25;fogHorizon;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;-294.4897,262.0515;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;3;250.8557,211.5425;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;SkyShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;Background;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;38;0;43;0
WireConnection;42;0;38;0
WireConnection;42;1;44;0
WireConnection;40;0;42;0
WireConnection;45;0;40;0
WireConnection;45;1;41;0
WireConnection;32;0;27;0
WireConnection;32;1;31;0
WireConnection;33;0;32;0
WireConnection;48;0;45;0
WireConnection;49;0;48;0
WireConnection;49;1;46;0
WireConnection;36;0;33;0
WireConnection;29;11;26;0
WireConnection;29;9;28;0
WireConnection;29;10;36;0
WireConnection;47;0;49;0
WireConnection;30;0;29;0
WireConnection;39;0;47;0
WireConnection;25;0;30;0
WireConnection;4;1;5;0
WireConnection;21;0;16;0
WireConnection;21;1;19;0
WireConnection;21;2;18;0
WireConnection;23;0;4;0
WireConnection;23;1;21;0
WireConnection;23;2;22;0
WireConnection;3;2;23;0
ASEEND*/
//CHKSM=9B5C4BBB8904F32E458DD3D785EE1F999CA6741D