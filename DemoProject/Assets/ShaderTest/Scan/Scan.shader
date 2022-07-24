// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_RimMin("RimMin", Range( -1 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 2)) = 1
		_RimColor("RimColor", Color) = (0,0,0,0)
		_InnerColor("InnerColor", Color) = (0,0,0,0)
		_RimIntensity("RimIntensity", Float) = 0
		_FlowEmiss("FlowEmiss", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_TexPower("TexPower", Float) = 0
		_FlowTilling("FlowTilling", Vector) = (0,0,0,0)
		_FlowIntensity("FlowIntensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		uniform float4 _InnerColor;
		uniform float4 _RimColor;
		uniform float _RimIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _TexPower;
		uniform float _RimMin;
		uniform float _RimMax;
		uniform float _FlowIntensity;
		uniform sampler2D _FlowEmiss;
		uniform float2 _FlowTilling;
		uniform float2 _Speed;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult6 = dot( ase_worldNormal , i.viewDir );
			float clampResult7 = clamp( dotResult6 , 0.0 , 1.0 );
			float smoothstepResult18 = smoothstep( _RimMin , _RimMax , ( 1.0 - clampResult7 ));
			float clampResult44 = clamp( ( pow( tex2D( _MainTex, uv_MainTex ).r , _TexPower ) + smoothstepResult18 ) , 0.0 , 1.0 );
			float4 lerpResult22 = lerp( _InnerColor , ( _RimColor * _RimIntensity ) , clampResult44);
			float4 FinalRimColor47 = lerpResult22;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult34 = (float2(ase_worldPos.x , ase_worldPos.z));
			float3 objToWorld36 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
			float2 appendResult39 = (float2(objToWorld36.x , objToWorld36.z));
			float4 FlowColor53 = ( _FlowIntensity * tex2D( _FlowEmiss, ( ( ( appendResult34 - appendResult39 ) * _FlowTilling ) + ( _Speed * _Time.y ) ) ) );
			o.Emission = ( FinalRimColor47 + FlowColor53 ).rgb;
			float FinalRimAlpha49 = clampResult44;
			o.Alpha = FinalRimAlpha49;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
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
				surfIN.worldNormal = IN.worldNormal;
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
0;0;1706;899;2515.574;48.61164;2.925547;True;True
Node;AmplifyShaderEditor.CommentaryNode;56;-1503.983,418.707;Inherit;False;1840.225;860.028;边缘光;20;4;6;7;10;12;18;42;43;1;41;44;21;23;24;20;22;47;49;5;19;;1,0.954827,0.1886792,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;55;-1514.22,1346.127;Inherit;False;2036.522;727.9103;流光;16;39;45;40;46;26;51;52;53;31;28;29;30;34;33;36;38;;0.2090602,0.8207547,0.24668,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-1453.087,1094.735;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;4;-1453.983,924.7603;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;38;-1464.22,1610.072;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;6;-1188.801,923.9661;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;36;-1282.974,1613.583;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;33;-1217.163,1396.127;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;39;-1034.916,1655.038;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;7;-979.8005,924.9661;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-991.9938,1428.396;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-818.7863,1147.959;Inherit;False;Property;_RimMax;RimMax;3;0;Create;True;0;0;0;False;0;False;1;1.83;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1427.758,612.707;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;299e8934b6bfd504e88fe87207c1ee0a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-1437.301,822.9293;Inherit;False;Property;_TexPower;TexPower;9;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-821.8001,1012.965;Inherit;False;Property;_RimMin;RimMin;2;0;Create;True;0;0;0;False;0;False;0;-0.37;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;10;-793.8001,923.9661;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;29;-771.2361,1964.037;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;28;-762.4576,1815.718;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;0;False;0;False;0,0;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;45;-843.6877,1650.456;Inherit;False;Property;_FlowTilling;FlowTilling;10;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-852.2999,1516.963;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-559.2361,1844.037;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;18;-504.7862,923.9597;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-562.6877,1537.456;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;43;-1059.758,804.707;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-839.5153,711.9821;Inherit;False;Property;_RimIntensity;RimIntensity;6;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-338.0217,767.2391;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-861.5154,506.982;Inherit;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0.6705883;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-415.129,1699.532;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-217.6976,1589.526;Inherit;False;Property;_FlowIntensity;FlowIntensity;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;44;-183.6959,808.5694;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-578.5153,669.9821;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;20;-563.7581,468.707;Inherit;False;Property;_InnerColor;InnerColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1744393,0.7095211,0.9245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-281.6977,1685.526;Inherit;True;Property;_FlowEmiss;FlowEmiss;7;0;Create;True;0;0;0;False;0;False;-1;None;d39b1da6e49bd4d43b28d1dd8ca76c22;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;70.30236,1637.526;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;22;-83.75803,612.707;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;108.242,606.3635;Inherit;False;FinalRimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;294.3023,1637.526;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;543.5386,990.3304;Inherit;False;47;FinalRimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;34.98364,838.1579;Inherit;False;FinalRimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;543.5386,1086.33;Inherit;False;53;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;798.2802,1288.781;Inherit;False;49;FinalRimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;815.5385,1022.33;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1098.782,974.118;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;36;0;38;0
WireConnection;39;0;36;1
WireConnection;39;1;36;3
WireConnection;7;0;6;0
WireConnection;34;0;33;1
WireConnection;34;1;33;3
WireConnection;10;0;7;0
WireConnection;40;0;34;0
WireConnection;40;1;39;0
WireConnection;30;0;28;0
WireConnection;30;1;29;0
WireConnection;18;0;10;0
WireConnection;18;1;12;0
WireConnection;18;2;19;0
WireConnection;46;0;40;0
WireConnection;46;1;45;0
WireConnection;43;0;1;1
WireConnection;43;1;42;0
WireConnection;41;0;43;0
WireConnection;41;1;18;0
WireConnection;31;0;46;0
WireConnection;31;1;30;0
WireConnection;44;0;41;0
WireConnection;24;0;21;0
WireConnection;24;1;23;0
WireConnection;26;1;31;0
WireConnection;52;0;51;0
WireConnection;52;1;26;0
WireConnection;22;0;20;0
WireConnection;22;1;24;0
WireConnection;22;2;44;0
WireConnection;47;0;22;0
WireConnection;53;0;52;0
WireConnection;49;0;44;0
WireConnection;32;0;48;0
WireConnection;32;1;54;0
WireConnection;0;2;32;0
WireConnection;0;9;50;0
ASEEND*/
//CHKSM=8DE10D550FB8DA7FB8DA0A6CFF56D4C11B125D22