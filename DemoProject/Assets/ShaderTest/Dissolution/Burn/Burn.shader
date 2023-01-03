// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Burn"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_Noise_Speed("Noise_Speed", Vector) = (0,-0.2,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_Softness("Softness", Range( 0 , 1)) = 0.5
		[HDR]_Color("Color", Color) = (1.720795,0.6548678,0,1)
		[HDR]_InnerColor("InnerColor", Color) = (0,0,0,0)
		_InnerColorLength("InnerColorLength", Range( 0 , 1)) = 0
		_InnerNoiseIntensity("InnerNoiseIntensity", Range( 0 , 1)) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (0.05,0,0,0)
		_Wind("Wind", Range( 0 , 10)) = 0
		_Float0("Float 0", Float) = 0.2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample1;
		uniform float2 _Vector0;
		uniform float _Wind;
		uniform sampler2D _Gradient;
		uniform float4 _Color;
		uniform float4 _InnerColor;
		uniform float _InnerColorLength;
		uniform float _InnerNoiseIntensity;
		uniform sampler2D _Noise;
		uniform float2 _Noise_Speed;
		uniform float4 _Noise_ST;
		uniform float _Softness;
		uniform sampler2D _TextureSample0;
		uniform float _Float0;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 panner81 = ( 1.0 * _Time.y * _Vector0 + v.texcoord.xy);
			float gradient24 = tex2Dlod( _Gradient, float4( v.texcoord.xy, 0, 0.0) ).r;
			float3 appendResult83 = (float3(( ( ( (tex2Dlod( _TextureSample1, float4( panner81, 0, 0.0) ).r*2.0 + -1.0) * _Wind ) * ( 1.0 - gradient24 ) ) + v.texcoord.xy.x ) , v.texcoord.xy.y , 0.0));
			v.vertex.xyz += appendResult83;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner6 = ( 1.0 * _Time.y * _Noise_Speed + uv_Noise);
			float norise23 = tex2D( _Noise, panner6 ).r;
			float smoothstepResult49 = smoothstep( 0.0 , ( _InnerColorLength + ( _InnerNoiseIntensity * norise23 ) ) , i.uv_texcoord.y);
			float4 lerpResult37 = lerp( _Color , _InnerColor , ( 1.0 - smoothstepResult49 ));
			float4 emission56 = lerpResult37;
			o.Emission = emission56.rgb;
			float gradient24 = tex2D( _Gradient, i.uv_texcoord ).r;
			float smoothstepResult20 = smoothstep( ( norise23 - _Softness ) , norise23 , gradient24);
			float2 appendResult98 = (float2(( i.uv_texcoord.x + ( (norise23*2.0 + -1.0) * _Float0 * ( 1.0 - gradient24 ) ) ) , i.uv_texcoord.y));
			float4 tex2DNode60 = tex2D( _TextureSample0, appendResult98 );
			float Shape62 = ( tex2DNode60.r * tex2DNode60.r );
			o.Alpha = ( smoothstepResult20 * Shape62 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
1920;0;1920;1019;3618.105;31.18555;2.142457;True;False
Node;AmplifyShaderEditor.CommentaryNode;27;-2252.828,-261.2093;Inherit;False;1424.241;708.3365;Comment;9;12;4;6;8;5;23;17;18;24;;0.9150943,0.717858,0.1942417,1;0;0
Node;AmplifyShaderEditor.Vector2Node;12;-2161.096,-4.523457;Inherit;False;Property;_Noise_Speed;Noise_Speed;1;0;Create;True;0;0;0;False;0;False;0,-0.2;-0.1,-0.4;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2202.828,-212.735;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;6;-1890.708,-107.1174;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;8;-1655.906,-132.9667;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;0;False;0;False;-1;fe5e45c9a89ac224dbbe244936fd3c2e;fe5e45c9a89ac224dbbe244936fd3c2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-2176.678,185.4073;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;5;-1296.526,-107.3011;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-1883.518,162.849;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;c5f1062ff1f19ee479caa14ec495c228;c5f1062ff1f19ee479caa14ec495c228;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1052.587,-111.9542;Inherit;True;norise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1313.285,187.1272;Inherit;True;gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-2807.609,642.6608;Inherit;False;23;norise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-2784.609,956.6608;Inherit;True;24;gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;93;-2617.609,646.6608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-2647.609,828.6608;Inherit;False;Property;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;0.2;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-2532.609,943.6608;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-2252.641,-1015.629;Inherit;False;1588.078;709.0328;Emission;12;53;39;52;54;55;48;16;49;50;37;56;38;;0.09019609,0.7285218,0.8980392,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2201.694,-502.5767;Inherit;False;Property;_InnerNoiseIntensity;InnerNoiseIntensity;7;0;Create;True;0;0;0;False;0;False;0;0.623;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;80;-1830,1165.369;Inherit;False;Property;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;0.05,0;0.05,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-2808.609,458.6608;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-2423.609,789.6608;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;79;-1908,998.3687;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2200.555,-422.5964;Inherit;False;23;norise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;81;-1568,933.3687;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2202.641,-580.7808;Inherit;False;Property;_InnerColorLength;InnerColorLength;6;0;Create;True;0;0;0;False;0;False;0;0.07;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1810.525,-445.19;Inherit;False;2;2;0;FLOAT;0.2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-2422.609,554.6608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;82;-1386,998.3687;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;fe5e45c9a89ac224dbbe244936fd3c2e;a9a55505407d3bf47b5ae0a3bf06a69f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;98;-2327.609,473.6608;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-1667.525,-514.19;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-1831.336,-669.6691;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;86;-1305.652,1363.633;Inherit;False;Property;_Wind;Wind;11;0;Create;True;0;0;0;False;0;False;0;0.2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;85;-1054.652,1076.333;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-957.6473,1724.335;Inherit;True;24;gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;49;-1497.884,-561.2681;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;60;-2172.886,639.3441;Inherit;True;Property;_TextureSample0;Texture Sample 0;8;0;Create;True;0;0;0;False;0;False;-1;dc46fd052d9fed54baf607ecae65f584;dc46fd052d9fed54baf607ecae65f584;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;50;-1317.316,-583.8047;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-1607.601,-782.9409;Inherit;False;Property;_InnerColor;InnerColor;5;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1.605559,1.429031,0.3446487,0.003921569;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;90;-699.5049,1697.762;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1862.29,652.0856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-1607.57,-965.6293;Inherit;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;0;False;0;False;1.720795,0.6548678,0,1;2.189029,0.5140929,0.1146088,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;25;-707.4475,313.0004;Inherit;True;23;norise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-717.7661,212.8383;Inherit;False;Property;_Softness;Softness;3;0;Create;True;0;0;0;False;0;False;0.5;0.4090792;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-960.6522,1417.633;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-401.8766,219.8256;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;37;-1155.07,-702.5323;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1681.433,646.0394;Inherit;False;Shape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-554.447,1500.294;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-709.9058,8.153591;Inherit;True;24;gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-650.9522,1150.633;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-888.5626,-708.4726;Inherit;False;emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;20;-160.6482,186.1362;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-70.61548,467.6426;Inherit;False;62;Shape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;144.9315,448.9474;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-153.9508,-138.8398;Inherit;False;56;emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;83;-471.6522,1269.433;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;30;157,-185.2;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Burn;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;4;0
WireConnection;6;2;12;0
WireConnection;8;1;6;0
WireConnection;5;0;8;1
WireConnection;18;1;17;0
WireConnection;23;0;5;0
WireConnection;24;0;18;1
WireConnection;93;0;92;0
WireConnection;102;1;99;0
WireConnection;96;0;93;0
WireConnection;96;1;94;0
WireConnection;96;2;102;0
WireConnection;81;0;79;0
WireConnection;81;2;80;0
WireConnection;53;0;54;0
WireConnection;53;1;55;0
WireConnection;97;0;91;1
WireConnection;97;1;96;0
WireConnection;82;1;81;0
WireConnection;98;0;97;0
WireConnection;98;1;91;2
WireConnection;52;0;39;0
WireConnection;52;1;53;0
WireConnection;85;0;82;1
WireConnection;49;0;48;2
WireConnection;49;2;52;0
WireConnection;60;1;98;0
WireConnection;50;1;49;0
WireConnection;90;1;89;0
WireConnection;74;0;60;1
WireConnection;74;1;60;1
WireConnection;87;0;85;0
WireConnection;87;1;86;0
WireConnection;22;0;25;0
WireConnection;22;1;21;0
WireConnection;37;0;16;0
WireConnection;37;1;38;0
WireConnection;37;2;50;0
WireConnection;62;0;74;0
WireConnection;88;0;87;0
WireConnection;88;1;90;0
WireConnection;84;0;88;0
WireConnection;84;1;79;1
WireConnection;56;0;37;0
WireConnection;20;0;26;0
WireConnection;20;1;22;0
WireConnection;20;2;25;0
WireConnection;59;0;20;0
WireConnection;59;1;61;0
WireConnection;83;0;84;0
WireConnection;83;1;79;2
WireConnection;30;2;57;0
WireConnection;30;9;59;0
WireConnection;30;11;83;0
ASEEND*/
//CHKSM=CAFBEF7B703D04507D80C3BBD0D93AD72B60C385