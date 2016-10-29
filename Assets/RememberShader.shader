// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "My Shaders/Skin Shader 2" {
	Properties{
		_Color("Color", Color) = (1,0,0,1)
		_specularColor("Specular", Color) = (1,0,1,1)
		_specularRollof("Specular Rollof", Range(0.1, 10)) = 5
		_specularSize("Specular size", Range(-2, 0)) = 0.5

	}
		SubShader{
			Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM

			float4 _Color;
			float4 lightDirection;
			float4 _specularColor;
			float _specularRollof;
			float _specularSize;
			uniform float4 _LightColor0;

			#pragma vertex vertexShader
			#pragma fragment fragmentShader
		
			struct vertexShaderIn {
				float4 vertexPos : POSITION;
				float3 normal : NORMAL;

			};

			struct vertexShaderOut {
				float4 color : TEXCOORD0;
				float4 pos : SV_POSITION;

			};


			vertexShaderOut vertexShader(vertexShaderIn input) {
				vertexShaderOut o;

				float3 normalDirection = mul(unity_ObjectToWorld, input.normal); //Always have this, will covert local normal vectors to world

				//Difuse shading
				float3 lightPosition = _WorldSpaceLightPos0.xyz;
				float4 diffuseShading = max(0.0, dot(normalDirection, _WorldSpaceLightPos0.xyz)) *_LightColor0 + UNITY_LIGHTMODEL_AMBIENT; // dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

				
				//Specular Shading
				float3 cameraDirection = normalize(_WorldSpaceCameraPos);

				float4 specularShading = pow(max(0.0, dot(cameraDirection, reflect(-lightPosition, normalDirection ) ) + _specularSize), _specularRollof) *  _LightColor0 * _specularColor;
				float4 lightFinal = diffuseShading + specularShading;

				o.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Always have this, This will project correct "filled siluet shape"
				o.color = lightFinal;
				return o;
			}

			float4 fragmentShader(vertexShaderOut input) :COLOR {


			return input.color;
		}




		ENDCG
		}
	}
}