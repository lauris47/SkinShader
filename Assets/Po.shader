// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Simple Lighting" {
	Properties{
		_DiffuseColor("Diffuse Material Color", Color) = (1,0,0,1)
		_SpecColor("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
	}
		SubShader{
		Pass{

		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

#include "UnityCG.cginc"

		struct vertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};
	struct vertexOutput {
		float4 pos : SV_POSITION;
		float4 worldNormal : TEXCOORD0;
		float4 worldPosition : TEXCOORD1;
	};

	uniform float4 _DiffuseColor;
	uniform float4 _SpecColor;
	uniform float _Shininess;

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = unity_ObjectToWorld;
		float4x4 viewMatrix = UNITY_MATRIX_V;
		float4x4 projectionMatrix = UNITY_MATRIX_P;

		//Find the world position
		float4 worldPosition = mul(modelMatrix,input.vertex);

		//Find the normals in world coordinates
		float4x4 modelMatrixInverse = unity_WorldToObject;
		float3 worldNormal = normalize(mul(float4(input.normal,0),transpose(modelMatrixInverse)).xyz);


		output.pos = mul(projectionMatrix,mul(viewMatrix,worldPosition));
		output.worldNormal = float4(worldNormal,0);
		output.worldPosition = worldPosition;

		return output;
	}

	float4 frag(vertexOutput input) : COLOR
	{
		float4 lightPosition = float4(unity_4LightPosX0[0],
		unity_4LightPosY0[0],
		unity_4LightPosZ0[0], 1.0);

	float3 worldNormal = normalize(input.worldNormal).xyz;

	float4 viewPosition = float4(_WorldSpaceCameraPos,1);

	//Calculate the light direction
	float3 lightDirection = normalize((lightPosition - input.worldPosition).xyz);

	//Calculate the diffuse reflection intensity
	float diffuseReflectionIntensity = max(0.0, dot(worldNormal,lightDirection));

	//Calculate viewDirection
	float3 viewDirection = normalize((viewPosition - input.worldPosition).xyz);

	//Calculate the specular reflection intensity
	float specularReflectionIntensity = pow(max(0.0, dot(reflect(-lightDirection, worldNormal),viewDirection)), _Shininess);

	return diffuseReflectionIntensity * _DiffuseColor + specularReflectionIntensity * _SpecColor;

	}
		ENDCG
	}
	}
}