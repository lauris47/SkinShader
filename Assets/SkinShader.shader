// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "My Shaders/Skin Shader"
{
	Properties
	{
		_Color("My texture", Color) = (0.9, 0.8, 0.6, 1) //Main color will be simmilar Skin Color by default
		_ColorTwo("My texture", Color) = (0.9, 0.5, 0.4, 1) //Main color will be simmilar Skin Color by default
		_Texture("Texture",2D) = "White" {}
	}
		SubShader{
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vort
			#pragma fragment frog


			uniform float4 _Color, _ColorTwo;
			uniform float4 addShade;
			uniform sampler2D _Texture;

			float4 lightDir0;
			float3 skinAgainstLightShine;
			//Unity will recognize this:
			float4 _LightColor0;
			
			//Used as input for vertexShader function
			struct vertexIn {
				float4 vertexPos : POSITION;
				float4 normal: NORMAL;
			};
			//Used as output for vertexShader function, they have to be defined in vertexShader function
			struct vertexOut {
				float4 pos : SV_POSITION;
				float4 color: TEXCOORD0; //it is only the semantics that are used to determine which vertex output parameters correspond to which fragment input parameters

			};


			vertexOut vort(vertexIn input) {
				vertexOut output;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Position shape verts in correcto position inside unity

				//Vertex Vectors
				float3 normalDirection = normalize(mul(input.normal, unity_WorldToObject)); //Will multiply face normal direction with world2object, to make normal vectors of object into world normals size
				float3 lightPosition = _WorldSpaceLightPos0.xyz; //_WorldSpaceLightDir0 is predefined, so no need to inniciate it at thte top, its also normalized autoatically
				float3 cameraAngleToNormal = max(0, (float3(1, 1, 1) - dot(normalDirection, _WorldSpaceCameraPos))); //Angle between face and camera. I want skin to be shiny when agnle is closer to 0, therefor I inveert it by subs

				//Lighting
				float3 diffuseShading = max(0, dot(lightPosition, normalDirection)); //Values from 0 to 1 with max() help. dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)
				float3 diffuseShadingAmbient = diffuseShading * _LightColor0.xyzw + UNITY_LIGHTMODEL_AMBIENT;//White highlits will hapen, as color will exceeed value of 1 at certain brigtest pioints, thats why we don't normalize diffuseReflection
				
				// To make skin shine against light source
				if (0.3 < dot(lightPosition, normalDirection))
				{
					skinAgainstLightShine = cameraAngleToNormal * _LightColor0.xyzw;
				}
				else {
					skinAgainstLightShine = 0;
				}

				
				output.color = float4(_Color * diffuseShadingAmbient + skinAgainstLightShine, 1.0); // Color is normal direction multiplied by world position of object in its local position.



				//output.color = input.normal; //This would return representitive normal colors 1,0,0 normal > color 1,0,0; 0,1,0 normal 0,1,0...



				return output;
			}

			float4 frog(vertexOut input) : COLOR {  //Float4 as a COLOR for unity


				return input.color;
			}





			ENDCG

		}
	}
		//To make sure that if shader crashes, som other default shader will be assigned
		Fallback "Diffuse"
}

