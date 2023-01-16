// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Diamond"
{
	Properties
	{
		_ColorA("ColorA", Color) = (0,0,0,0)
		_RefractTex("RefractTex", CUBE) = "white" {}
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		_RefractIntensity("RefractIntensity", Float) = 0
		_ReflectStrength("ReflectStrength", Float) = 1
		_RimPower("RimPower", Float) = 0
		_RimScale("RimScale", Float) = 2
		_RimBias("RimBias", Float) = 0

	}
	
	SubShader
	{
		

	LOD 100
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		
		
		Pass
		{
			Name "First"
			Blend Off
			ZWrite On
			ZTest LEqual
			Cull Front
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _ColorA;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _RefractIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 temp_output_19_0 = reflect( -ase_worldViewDir , ase_worldNormal );
				float4 texCUBENode17 = texCUBE( _ReflectTex, temp_output_19_0 );
				float4 temp_output_24_0 = ( _ColorA * texCUBE( _RefractTex, temp_output_19_0 ) * texCUBENode17 * _RefractIntensity );
				
				
				finalColor = temp_output_24_0;
				return finalColor;
			}
			ENDCG
		}
		
		Pass
		{
			Name "Second"
			Blend One One
			ZWrite On
			ZTest LEqual
			Cull Back
			
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _ColorA;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _RefractIntensity;
			uniform float _ReflectStrength;
			uniform float _RimPower;
			uniform float _RimScale;
			uniform float _RimBias;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 temp_output_19_0 = reflect( -ase_worldViewDir , ase_worldNormal );
				float4 texCUBENode17 = texCUBE( _ReflectTex, temp_output_19_0 );
				float4 temp_output_24_0 = ( _ColorA * texCUBE( _RefractTex, temp_output_19_0 ) * texCUBENode17 * _RefractIntensity );
				float dotResult31 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult35 = clamp( dotResult31 , 0.0 , 1.0 );
				float saferPower38 = abs( ( 1.0 - clampResult35 ) );
				float temp_output_38_0 = pow( saferPower38 , _RimPower );
				float4 temp_output_26_0 = ( temp_output_24_0 + ( texCUBENode17 * _ReflectStrength * temp_output_38_0 ) );
				
				
				finalColor = ( temp_output_26_0 + ( temp_output_26_0 * ( ( temp_output_38_0 * _RimScale ) + _RimBias ) ) );
				return finalColor;
			}
			ENDCG
		}
		
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-16.66667;240.6667;1200;803;3114.019;33.04114;3.188508;True;False
Node;AmplifyShaderEditor.WorldNormalVector;34;-1915.389,717.4526;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;33;-1908.889,894.2535;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;31;-1595.589,804.5525;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;18;-1540.373,62.33369;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;21;-1437.49,223.1676;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;35;-1385.865,805.0615;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;22;-1321.84,112.3422;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1054.59,1052.532;Inherit;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;0;False;0;False;0;9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;36;-1187.862,805.0615;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;19;-1179.49,171.1676;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-797.0488,1019.956;Inherit;False;Property;_RimScale;RimScale;6;0;Create;True;0;0;0;False;0;False;2;9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;38;-911.8895,805.5971;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-931.2128,422.728;Inherit;True;Property;_ReflectTex;ReflectTex;2;0;Create;True;0;0;0;False;0;False;-1;None;987d4dcc6ad72d1419fc07270f637f0f;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-423.3503,430.2953;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;0;False;0;False;0;3.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-687.7485,638.6387;Inherit;False;Property;_ReflectStrength;ReflectStrength;4;0;Create;True;0;0;0;False;0;False;1;2.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;-392.5498,-40.74077;Inherit;False;Property;_ColorA;ColorA;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6981132,0.3578366,0.1887978,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-941.0582,142.7715;Inherit;True;Property;_RefractTex;RefractTex;1;0;Create;True;0;0;0;False;0;False;-1;None;92e935b052c6e0a4aba4b9a3b323cae3;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-446.3975,613.2363;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-119.7405,111.6421;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-514.5065,1038.482;Inherit;False;Property;_RimBias;RimBias;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-619.314,807.1265;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-36.51833,591.1878;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-265.1328,808.9152;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;118.296,721.1578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;257.945,587.8702;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;453.0562,583.6538;Float;False;False;-1;2;ASEMaterialInspector;100;9;New Amplify Shader;968f3c9aa3835d349a463d306f84ef08;True;Second;0;1;Second;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;False;0;True;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;True;0;False;-1;False;False;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;173.2411,110.4399;Float;False;True;-1;2;ASEMaterialInspector;100;9;Diamond;968f3c9aa3835d349a463d306f84ef08;True;First;0;0;First;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;False;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;True;0;False;-1;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;2;True;True;False;;False;0
WireConnection;31;0;34;0
WireConnection;31;1;33;0
WireConnection;35;0;31;0
WireConnection;22;0;18;0
WireConnection;36;0;35;0
WireConnection;19;0;22;0
WireConnection;19;1;21;0
WireConnection;38;0;36;0
WireConnection;38;1;39;0
WireConnection;17;1;19;0
WireConnection;16;1;19;0
WireConnection;27;0;17;0
WireConnection;27;1;28;0
WireConnection;27;2;38;0
WireConnection;24;0;13;0
WireConnection;24;1;16;0
WireConnection;24;2;17;0
WireConnection;24;3;25;0
WireConnection;41;0;38;0
WireConnection;41;1;42;0
WireConnection;26;0;24;0
WireConnection;26;1;27;0
WireConnection;44;0;41;0
WireConnection;44;1;45;0
WireConnection;47;0;26;0
WireConnection;47;1;44;0
WireConnection;48;0;26;0
WireConnection;48;1;47;0
WireConnection;9;0;48;0
WireConnection;8;0;24;0
ASEEND*/
//CHKSM=0470A6EA2ECBAEABCBB8323940F335D0E5F01E18