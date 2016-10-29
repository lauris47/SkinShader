// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "My Shaders/Skin Shader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 0.8, 0.6, 1) //Main color will be simmilar Skin Color by default
		_Specular("Specular Color", Color) = (0.9, 0.5, 0.4, 1) //Main color will be simmilar Skin Color by default
		_Shininess("Shininess", Range(0.1,10)) = 5
		_Transparency("Transparency", Range(0.1,10)) = 5
		_TransparetCut("TransparetCut", Range(-1,1)) = 1
		_Texture("Texture",2D) = "White" {}
	}
		SubShader{


		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vort
			#pragma fragment frog


			uniform float4 _Color, _Specular;
					float _Shininess;
			uniform float4 addShade;
			uniform sampler2D _Texture;


			float4 lightDir0;
			float lightStrength;


			//Unity will recognize this:
			float4 _LightColor0;


			struct vertexIn {
				float4 vertexPos : POSITION;

				float4 colorOfTexture : TEXCOORD0;
			};

			struct vertexOut {
				float4 pos : SV_POSITION;
				float4 tex1 : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float4 normal: NORMAL;
			};

			vertexOut vort(vertexIn input) {
				vertexOut output;

				output.tex1 = input.colorOfTexture; //Will multiply face normal direction with world2object, to make normal vectors of object into world normals size
				output.posWorld = mul(unity_ObjectToWorld, input.vertexPos);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Position shape verts in correcto position inside unity

				return output;
			}

			//Works per fragment/pixel, computationaly expensive in comparison to vertex program
			float4 frog(vertexOut input) : COLOR {  //Float4 as a COLOR for unity

				// float distance;
				// float lightStrength;
				//Vertex Vectors
				float3 normalDirection = mul(unity_ObjectToWorld, input.normal);; // input from vertex function
				float3 lightPosition = normalize(_WorldSpaceLightPos0.xyz); //_WorldSpaceLightDir0 is predefined, so no need to inniciate it at the top, it's also normalized automatically
				// float3 cameraAngleToNormal = max(0.0, float3(1, 1, 1) - dot(normalDirection, _WorldSpaceCameraPos)); //Angle between face and camera. I want skin to be shiny when agnle is closer to 0, therefor I inveert it by subs, both in dot() are normalized before
				// float3 cameraToVertexAngle = normalize(_WorldSpaceCameraPos - input.posWorld); // Normalized vector length from vertex to camera. Not using defined before normalDirection, becasue I don't want to normalize it alone

				//float4 textureColor = sampler2D(_Texture, input.normalDirection.xy);

				//Lighting
				float4 textureColor = tex2D(_Texture, input.tex1.xy);
				float3 diffuseShading = _LightColor0.xyzw * max(0.0, dot(normalDirection, lightPosition)); //Values from 0 to 1 with max() help. dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)
				// float3 specularReflection = max(0.0, dot(normalDirection, lightPosition) * pow(dot(reflect(-lightPosition, normalDirection), cameraToVertexAngle), _Shininess));

				//max(0.0, dot(normalDirection, lightPosition)) * pow(max(0.0, dot(reflect(-lightPosition, normalDirection), cameraToVertexAngle)), _Shininess);
				// To make skin shine against light source

				// float3 skinAgainstLightShine = max(0.0, cameraAngleToNormal *  dot(lightPosition, normalDirection)); //Fix: shine oposite the light still appears
				// float3 lightFinal = diffuseShading  + specularReflection;

				return float4(textureColor * diffuseShading, 1.0);// + UNITY_LIGHTMODEL_AMBIENT/*+ skinAgainstLightShine Specular light does almost the same*/, 1.0); // Color is normal direction multiplied by world position of object in its local position.

			}
			ENDCG

		}
		//For spot Light
		Pass{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One

			CGPROGRAM
			#pragma vertex vort
			#pragma fragment frog

			uniform float4 _Color, _Specular;
					float _Shininess;
			uniform float4 addShade;
			uniform sampler2D _Texture;

			float4 lightDir0;
			float lightStrength;
			float4 _LightColor0;

			struct vertexIn {
				float4 vertexPos : POSITION;
				float4 normal: NORMAL;
				float4 colorOfTexture: TEXCOORD0;
			};

			struct vertexOut {
				float4 pos : SV_POSITION;
				float4 tex1 : TEXCOORD0;
				//float4 posWorld : TEXCOORD1;
			};

			vertexOut vort(vertexIn input) {
				vertexOut output;
				output.tex1 = input.colorOfTexture;
				//	output.posWorld = normalize(mul(unity_ObjectToWorld, input.vertexPos));
				output.pos = mul(UNITY_MATRIX_MVP, input.vertexPos);

				return output;
			}

			float4 frog(vertexOut input) : COLOR{
			
				//	float lightDistance;
				//	float lightStrength;
				//	float3 normalDirection = input.tex1;
				//	float3 lightPosition;
				//	float3 cameraAngleToNormal = max(0.0, float3(1, 1, 1) - normalize(dot(normalDirection, _WorldSpaceCameraPos))); 
				//	float3 cameraToVertexAngle = normalize(_WorldSpaceCameraPos - input.posWorld); 
				lightStrength = 0;

					/*
				if (!_WorldSpaceLightPos0.w == 0.0) {

					lightDistance = length(_WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, input.posWorld));
					lightStrength = 1 / lightDistance;
					lightPosition = normalize(_WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, input.posWorld));
				}
				else {
					//This will never execute
					lightStrength = 1;
					lightPosition = normalize(_WorldSpaceLightPos0.xyz);
				}*/
				float4 textureColor = tex2D(_Texture, input.tex1.xy);
				//	float3 diffuseShading = _LightColor0.xyzw * max(0.0, dot(normalDirection, lightPosition)) * lightStrength;
				//	float3 specularReflection = max(0.0, dot(normalDirection, lightPosition) * pow(dot(reflect(-lightPosition, normalDirection), cameraToVertexAngle), _Shininess));
				//	float3 lightFinal = diffuseShading + specularReflection;

				return float4(textureColor);
			}
				ENDCG
			}
	}
		Fallback "Diffuse"
}


//Call back
//Call front
//and then -normal
// to make back faces als orenderey