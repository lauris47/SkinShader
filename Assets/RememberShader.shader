Shader "My Shaders/RememberShader" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_SpecularColor("Specular", Color) = (1,1,1,1)
	}
		SubShader{
			Pass{
			CGPROGRAM

			float4 _Color;
			float4 lightDirection;

			float4 _LightColor0;

			#pragma vertex vertexShader
			#pragma fragment fragmentShader
		
			struct vertexShaderIn {
				float3 normal : NORMAL;
				float4 vertexPos : POSITION;

			};

			struct vertexShaderOut {
				float4 color : TEXCOORD0;
				float4 pos : SV_POSITION;

			};


			vertexShaderOut vertexShader(vertexShaderIn input) {
				vertexShaderOut o;

				o.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Always have this!

				float3 lightPosition = _WorldSpaceLightPos0.xyz;
				float4 diffuseShading = max(0, dot(lightPosition, input.normal)); //Values from 0 to 1 with max() help. dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

				float4 lightColor = diffuseShading * _LightColor0.xyzw + UNITY_LIGHTMODEL_AMBIENT; //diffuseShading(Vertexes with value closer to 1 will be brighter) MULTIPLIED by Light color and added with ambient color (general brioghness)


					




				o.color = _Color * lightColor;
				return o;
			}


		float4 fragmentShader(vertexShaderOut input) :COLOR {


			return input.color;
		}




		ENDCG
		}
	}
}