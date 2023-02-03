// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NyxEffect"
{
	Properties
	{
		_EffectBaseColor("EffectBaseColor", Color) = (0,0,0,0)
		_EmissMap("EmissMap", 2D) = "white" {}
		_FlowSpeed("FlowSpeed", Vector) = (0.5,0.5,0,0)
		_OpaLength("OpaLength", Range( 0 , 1)) = 0
		_EmissIntensity("EmissIntensity", Float) = 1
		_NoiseMap("NoiseMap", 2D) = "black" {}
		_NoiseIntensity("NoiseIntensity", Float) = 0.1
		_FadeIntensity("FadeIntensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _EffectBaseColor;
		uniform sampler2D _EmissMap;
		uniform float2 _FlowSpeed;
		uniform float4 _EmissMap_ST;
		uniform sampler2D _NoiseMap;
		uniform float4 _NoiseMap_ST;
		uniform float _NoiseIntensity;
		uniform float _OpaLength;
		uniform float _EmissIntensity;
		uniform float _FadeIntensity;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_EmissMap = i.uv_texcoord * _EmissMap_ST.xy + _EmissMap_ST.zw;
			float2 panner7 = ( 1.0 * _Time.y * _FlowSpeed + uv_EmissMap);
			float2 uv_NoiseMap = i.uv_texcoord * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
			float smoothstepResult13 = smoothstep( _OpaLength , 1.0 , i.uv_texcoord.y);
			o.Emission = ( _EffectBaseColor * tex2D( _EmissMap, ( panner7 + ( (tex2D( _NoiseMap, uv_NoiseMap )).rg * _NoiseIntensity * smoothstepResult13 ) ) ) * _EmissIntensity ).rgb;
			float smoothstepResult33 = smoothstep( 0.0 , 0.5 , ( 1.0 - abs( (i.uv_texcoord.x*2.0 + -1.0) ) ));
			o.Alpha = ( smoothstepResult33 * pow( ( 1.0 - smoothstepResult13 ) , _FadeIntensity ) );
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
1920;0;1920;1019;1679.627;-381.0574;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-1742.599,428.4571;Inherit;False;0;35;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;35;-1497.223,405.2112;Inherit;True;Property;_NoiseMap;NoiseMap;6;0;Create;True;0;0;0;False;0;False;-1;11599a85915cd2540b97dd99f49ea1c2;11599a85915cd2540b97dd99f49ea1c2;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-909.7777,865.876;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-997.5803,1069.242;Inherit;False;Property;_OpaLength;OpaLength;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1247.311,66.91132;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1189.258,549.9125;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;7;0;Create;True;0;0;0;False;0;False;0.1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;43;-1163.383,404.2497;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;13;-609.6873,1053.199;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;8;-1245.595,225.8495;Inherit;False;Property;_FlowSpeed;FlowSpeed;3;0;Create;True;0;0;0;False;0;False;0.5,0.5;-0.2,-0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;30;-635.7361,890.1466;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;7;-995.6375,72.12653;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-963.1194,408.7981;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;31;-431.3622,890.9163;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;16;-396.4497,1052.482;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-283.1255,891.9763;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-850.8042,241.0483;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-372.6272,1188.057;Inherit;False;Property;_FadeIntensity;FadeIntensity;8;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-717.0863,42.30958;Inherit;True;Property;_EmissMap;EmissMap;1;0;Create;True;0;0;0;False;0;False;-1;05ade53fe1dbca84398e1b6214382dc6;05ade53fe1dbca84398e1b6214382dc6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-687.4221,-270.5667;Inherit;False;Property;_EffectBaseColor;EffectBaseColor;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1647059,0.4514371,0.6901961,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-129.873,891.8848;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-450.0074,220.7563;Inherit;False;Property;_EmissIntensity;EmissIntensity;5;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;45;-182.6272,1098.057;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-268.4922,41.22491;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;71.7945,977.5677;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;4;332.0593,4.768372E-07;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;NyxEffect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;5;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;35;1;38;0
WireConnection;43;0;35;0
WireConnection;13;0;12;2
WireConnection;13;1;14;0
WireConnection;30;0;12;1
WireConnection;7;0;6;0
WireConnection;7;2;8;0
WireConnection;40;0;43;0
WireConnection;40;1;36;0
WireConnection;40;2;13;0
WireConnection;31;0;30;0
WireConnection;16;0;13;0
WireConnection;32;0;31;0
WireConnection;44;0;7;0
WireConnection;44;1;40;0
WireConnection;5;1;44;0
WireConnection;33;0;32;0
WireConnection;45;0;16;0
WireConnection;45;1;46;0
WireConnection;10;0;2;0
WireConnection;10;1;5;0
WireConnection;10;2;18;0
WireConnection;34;0;33;0
WireConnection;34;1;45;0
WireConnection;4;2;10;0
WireConnection;4;9;34;0
ASEEND*/
//CHKSM=195CF9545CE29BAC83211E6100333AE7994A596A