// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Glass"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_RefractMatcap("RefractMatcap", 2D) = "white" {}
		_RefractIntensity("RefractIntensity", Float) = 1
		_RefractColor("RefractColor", Color) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_ObjectHeight("ObjectHeight", Float) = 0.35
		_ObjectPivotOffset("ObjectPivotOffset", Float) = 0
		_dirty("dirty", 2D) = "black" {}
		_logo("logo", 2D) = "black" {}
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
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _Matcap;
		uniform float4 _RefractColor;
		uniform sampler2D _RefractMatcap;
		uniform sampler2D _TextureSample0;
		uniform float _ObjectPivotOffset;
		uniform float _ObjectHeight;
		uniform sampler2D _dirty;
		uniform float4 _dirty_ST;
		uniform float _RefractIntensity;
		uniform sampler2D _logo;
		uniform float4 _logo_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult40 = normalize( mul( UNITY_MATRIX_V, float4( reflect( -i.viewDir , ase_worldNormal ) , 0.0 ) ).xyz );
			float temp_output_42_0 = (normalizeResult40).x;
			float temp_output_43_0 = (normalizeResult40).y;
			float temp_output_45_0 = ( (normalizeResult40).z + 1.0 );
			float2 matcap_improve58 = ( ( (normalizeResult40).xy / ( sqrt( ( ( temp_output_42_0 * temp_output_42_0 ) + ( temp_output_43_0 * temp_output_43_0 ) + ( temp_output_45_0 * temp_output_45_0 ) ) ) * 2.0 ) ) + 0.5 );
			float4 tex2DNode9 = tex2D( _Matcap, matcap_improve58 );
			float dotResult66 = dot( i.viewDir , ase_worldNormal );
			float smoothstepResult82 = smoothstep( 0.0 , 1.0 , dotResult66);
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld86 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult93 = (float2(0.5 , ( ( ( ase_worldPos.y - objToWorld86.y ) - _ObjectPivotOffset ) / _ObjectHeight )));
			float2 uv_dirty = i.uv_texcoord * _dirty_ST.xy + _dirty_ST.zw;
			float clampResult100 = clamp( ( ( 1.0 - smoothstepResult82 ) + tex2D( _TextureSample0, appendResult93 ).r + tex2D( _dirty, uv_dirty ).a ) , 0.0 , 1.0 );
			float thickness77 = clampResult100;
			float temp_output_70_0 = ( thickness77 * _RefractIntensity );
			float4 lerpResult72 = lerp( ( _RefractColor * 0.5 ) , ( tex2D( _RefractMatcap, ( matcap_improve58 + temp_output_70_0 ) ) * _RefractColor ) , temp_output_70_0);
			float2 uv_logo = i.uv_texcoord * _logo_ST.xy + _logo_ST.zw;
			float4 tex2DNode101 = tex2D( _logo, uv_logo );
			float4 lerpResult103 = lerp( ( tex2DNode9 + lerpResult72 ) , tex2DNode101 , tex2DNode101.a);
			o.Emission = lerpResult103.rgb;
			o.Alpha = max( max( tex2DNode9.r , thickness77 ) , tex2DNode101.a );
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
56.66667;257.3333;1536;610.3334;1141.872;59.72783;1.879711;True;False
Node;AmplifyShaderEditor.CommentaryNode;59;-3102.942,-444.2024;Inherit;False;2112.93;674.472;MatcapImprove;24;34;35;32;37;38;39;40;41;52;57;44;47;48;46;45;43;42;50;49;51;53;54;56;58;;0.3465832,0.9622642,0.1951762,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;32;-3052.942,-301.9367;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;35;-2864.731,-181.109;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;34;-2827.386,-298.238;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;38;-2622.38,-394.2024;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ReflectOpNode;37;-2657.38,-282.2023;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2459.38,-353.2024;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;97;-3112.561,427.5062;Inherit;False;2012.485;1111.829;Thickness;18;77;94;68;98;89;93;82;66;91;95;90;67;64;96;88;87;86;100;;0.327044,0.9867058,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;87;-3030.367,896.239;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;40;-2300.38,-353.2024;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;86;-3062.561,1078.664;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;96;-2775.119,1206.108;Inherit;False;Property;_ObjectPivotOffset;ObjectPivotOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;-2797.825,952.9857;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2361.438,114.2695;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;44;-2379.037,-4.630605;Inherit;False;FLOAT;2;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-2531.954,1205.071;Inherit;False;Property;_ObjectHeight;ObjectHeight;6;0;Create;True;0;0;0;False;0;False;0.35;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;42;-2219.437,-202.5306;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;43;-2277.437,-94.03065;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;64;-2680.675,644.5062;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;67;-2682.675,477.5062;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-2194.438,41.26954;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-2573.981,1047.486;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;66;-2380.674,564.5062;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;91;-2378.014,1046.449;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-2029.537,34.36939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2030.337,-98.53067;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2033.337,-214.5305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1827.637,-119.5309;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;82;-2158.976,564.9922;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-2237.782,953.6026;Inherit;False;FLOAT2;4;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;68;-1962.675,565.5062;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;98;-1996.075,1253.362;Inherit;True;Property;_dirty;dirty;8;0;Create;True;0;0;0;False;0;False;-1;27b90822b20588a4f88dc20805a6b3f1;27b90822b20588a4f88dc20805a6b3f1;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SqrtOpNode;51;-1674.437,-119.331;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1684.551,-11.40258;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;89;-2029.8,925.6255;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;c654691e68d99c44c86627406c2420b2;c654691e68d99c44c86627406c2420b2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1527.477,-102.3398;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;41;-2122.38,-357.2024;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-1693.927,750.4684;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;52;-1662.766,-347.9351;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;100;-1530.746,750.1756;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1525.01,-259.1304;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1363.422,745.1628;Inherit;True;thickness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-1373.018,-348.8106;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-1222.01,-354.1307;Inherit;False;matcap_improve;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-799.3444,735.5367;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-785.2061,623.6091;Inherit;False;77;thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-713.6998,436.7653;Inherit;False;58;matcap_improve;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-582.3443,643.5367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-409.2286,542.9881;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;76;-224.5639,728.4161;Inherit;False;Property;_RefractColor;RefractColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.05098036,0.5907431,0.9333333,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;-255.0405,422.2061;Inherit;True;Property;_RefractMatcap;RefractMatcap;2;0;Create;True;0;0;0;False;0;False;-1;2b080761da3fadc429cc52815e37a507;369677b5da8d79b4691eb711fa44a743;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;84;-154.9001,947.639;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;152.9091,884.7001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;128.97,522.9713;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-364.5574,43.10682;Inherit;False;58;matcap_improve;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;72;322.2912,597.0417;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-78.36433,19.02387;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;0;False;0;False;-1;a69932f6f37b5ba4a9206e626a757927;2b080761da3fadc429cc52815e37a507;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;81;57.29565,265.9924;Inherit;False;77;thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-3101.772,-1035.834;Inherit;False;1887.057;500.76;MatcapUV2;12;15;18;19;21;12;13;14;24;25;26;28;29;;0.759434,1,0.9755236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;11;-3103.2,-1538.494;Inherit;False;1071;335;MatcapUV;6;2;4;3;5;6;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;101;221.1643,349.0391;Inherit;True;Property;_logo;logo;9;0;Create;True;0;0;0;False;0;False;-1;ce7a0af0b9894564b803cca713a9a86e;ce7a0af0b9894564b803cca713a9a86e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;75;341.4725,182.0697;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;519.8176,25.36462;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;103;907.0334,26.33564;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;15;-3051.772,-980.8588;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;105;536.5334,178.3907;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;28;-1683.185,-849.9406;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-2479.201,-1448.794;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-2256.201,-1453.494;Inherit;False;matcap_uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;26;-2021.644,-901.5859;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;4;-2980.2,-1488.494;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-1866.578,-851.2463;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2578.301,-769.2738;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;13;-2742.101,-821.2739;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2830.201,-1446.494;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;24;-2170.304,-855.2909;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SwizzleNode;5;-2681.201,-1452.494;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;18;-2830.254,-985.8339;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;19;-2573.253,-924.8339;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1445.715,-854.8312;Inherit;False;matcap_uv_2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-3053.2,-1386.494;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;21;-2383.896,-856.1271;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-2816.701,-718.0739;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;1139.713,-19.63162;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;32;0
WireConnection;37;0;34;0
WireConnection;37;1;35;0
WireConnection;39;0;38;0
WireConnection;39;1;37;0
WireConnection;40;0;39;0
WireConnection;88;0;87;2
WireConnection;88;1;86;2
WireConnection;44;0;40;0
WireConnection;42;0;40;0
WireConnection;43;0;40;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;95;0;88;0
WireConnection;95;1;96;0
WireConnection;66;0;67;0
WireConnection;66;1;64;0
WireConnection;91;0;95;0
WireConnection;91;1;90;0
WireConnection;49;0;45;0
WireConnection;49;1;45;0
WireConnection;48;0;43;0
WireConnection;48;1;43;0
WireConnection;47;0;42;0
WireConnection;47;1;42;0
WireConnection;50;0;47;0
WireConnection;50;1;48;0
WireConnection;50;2;49;0
WireConnection;82;0;66;0
WireConnection;93;1;91;0
WireConnection;68;0;82;0
WireConnection;51;0;50;0
WireConnection;89;1;93;0
WireConnection;53;0;51;0
WireConnection;53;1;54;0
WireConnection;41;0;40;0
WireConnection;94;0;68;0
WireConnection;94;1;89;1
WireConnection;94;2;98;4
WireConnection;52;0;41;0
WireConnection;52;1;53;0
WireConnection;100;0;94;0
WireConnection;77;0;100;0
WireConnection;56;0;52;0
WireConnection;56;1;57;0
WireConnection;58;0;56;0
WireConnection;70;0;80;0
WireConnection;70;1;71;0
WireConnection;73;0;63;0
WireConnection;73;1;70;0
WireConnection;62;1;73;0
WireConnection;83;0;76;0
WireConnection;83;1;84;0
WireConnection;85;0;62;0
WireConnection;85;1;76;0
WireConnection;72;0;83;0
WireConnection;72;1;85;0
WireConnection;72;2;70;0
WireConnection;9;1;60;0
WireConnection;75;0;9;1
WireConnection;75;1;81;0
WireConnection;74;0;9;0
WireConnection;74;1;72;0
WireConnection;103;0;74;0
WireConnection;103;1;101;0
WireConnection;103;2;101;4
WireConnection;105;0;75;0
WireConnection;105;1;101;4
WireConnection;28;0;25;0
WireConnection;6;0;5;0
WireConnection;8;0;6;0
WireConnection;26;0;24;1
WireConnection;25;0;26;0
WireConnection;25;1;24;0
WireConnection;14;0;13;0
WireConnection;14;1;12;0
WireConnection;3;0;4;0
WireConnection;3;1;2;0
WireConnection;24;0;21;0
WireConnection;5;0;3;0
WireConnection;18;0;15;0
WireConnection;19;0;18;0
WireConnection;29;0;28;0
WireConnection;21;0;19;0
WireConnection;21;1;14;0
WireConnection;1;2;103;0
WireConnection;1;9;105;0
ASEEND*/
//CHKSM=9CE93C8D12ED49A96FE49823C41F4DE54F6AA530