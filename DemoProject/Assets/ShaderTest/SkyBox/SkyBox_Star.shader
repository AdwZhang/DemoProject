// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SkyBox_Star"
{
	Properties
	{
		_StarTex("StarTex", 2D) = "white" {}
		_StarIntensity("StarIntensity", Float) = 100
		_StarNoise("StarNoise", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (1,1,0,0)
		_fog("fog", Color) = (0,0,0,0)
		_Float0("Float 0", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _StarTex;
		uniform float4 _StarTex_ST;
		uniform float _StarIntensity;
		uniform sampler2D _StarNoise;
		uniform float4 _StarNoise_ST;
		uniform float2 _Vector0;
		uniform float4 _fog;
		uniform float _Float0;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_StarTex = i.uv_texcoord * _StarTex_ST.xy + _StarTex_ST.zw;
			float4 tex2DNode1 = tex2D( _StarTex, uv_StarTex );
			float4 temp_cast_0 = (3.0).xxxx;
			float2 uv_StarNoise = i.uv_texcoord * _StarNoise_ST.xy + _StarNoise_ST.zw;
			float mulTime10 = _Time.y * 0.1;
			float4 lerpResult18 = lerp( ( tex2DNode1 + ( pow( tex2DNode1 , temp_cast_0 ) * _StarIntensity * tex2D( _StarNoise, ( uv_StarNoise + ( mulTime10 * _Vector0 ) ) ).r ) ) , _fog , _Float0);
			o.Emission = lerpResult18.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;0;1920;1019;1406.707;347.572;1;True;False
Node;AmplifyShaderEditor.Vector2Node;13;-1894.82,500.7874;Inherit;False;Property;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1908.138,377.9824;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1679.82,394.7874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1875.008,184.3947;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-2004.854,-493.4288;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-1504.82,243.7874;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1634.888,-140.7339;Inherit;False;Constant;_StarPow;StarPow;1;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1711.445,-494.1346;Inherit;True;Property;_StarTex;StarTex;0;0;Create;True;0;0;0;False;0;False;-1;bf74a574c7ad7694fbac2f8038fbaa84;bf74a574c7ad7694fbac2f8038fbaa84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;2;-1337.761,-164.2389;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;6;-1307.911,271.436;Inherit;True;Property;_StarNoise;StarNoise;2;0;Create;True;0;0;0;False;0;False;-1;cd31005260d895b4fb3d9d075143f534;cd31005260d895b4fb3d9d075143f534;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1219.654,93.8788;Inherit;False;Property;_StarIntensity;StarIntensity;1;0;Create;True;0;0;0;False;0;False;100;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-919.5057,108.8439;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;19;-528.7068,140.428;Inherit;False;Property;_fog;fog;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-477.5004,6.55808;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-488.7068,380.428;Inherit;False;Property;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;-240.7068,119.428;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;SkyBox_Star;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;10;0
WireConnection;14;1;13;0
WireConnection;12;0;11;0
WireConnection;12;1;14;0
WireConnection;1;1;17;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;6;1;12;0
WireConnection;4;0;2;0
WireConnection;4;1;5;0
WireConnection;4;2;6;1
WireConnection;15;0;1;0
WireConnection;15;1;4;0
WireConnection;18;0;15;0
WireConnection;18;1;19;0
WireConnection;18;2;20;0
WireConnection;0;2;18;0
ASEEND*/
//CHKSM=66013A8ED95553C5E404B514A1FDFD24E952C352