// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "My Shaders/Skin Shader New" {
	Properties{
		_Texture("Texture", 2D) = "White" {}
		_skinShineColor("Skin Shine Color", Color) = (1,1,0,1)
		_skinShinePower("Skin Shine Strength", Range(0, 1)) = 0.5
		_BumpMap("BumpMap", 2D) = "bump" {}
		_bumpStrength("Bump Strength", Range(-1, 1)) = 0.2
		//Create if statement, if there is no texture, so it would use color instead. 
		//_Color("Color", Color) = (1,0,0,1)

		_SpecularMap("Specular Map", 2D) = "specular" {}
		_specularColor("Specular Color", Color) = (1,1,1,1)
		_specularRollof("Specular Rollof", Range(10, 0.1)) = 5
		_specularSize("Specular Size", Range(-2, 0)) = 0.5




	}
		SubShader{

			Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM

			//float4 _Color;
			float4 lightDirection;
			float4 _skinShineColor;
			float4 _specularColor;
			float _specularRollof;
			float _specularSize;
			float4 _LightColor0;
			sampler2D _Texture;
			sampler2D _BumpMap;
			sampler2D _SpecularMap;
			float lightStrength;
			float _skinShinePower;
			float _bumpStrength;

			#pragma vertex vertexShader
			#pragma fragment fragmentShader

			struct vertexShaderIn {
				float4 vertexPos : POSITION;
				float3 normal : NORMAL;
				float4 colorOfTexture : TEXCOORD0;
				float4 tangent : TANGENT; // Vector that is tangent to the face normal 


			};

			struct vertexShaderOut {
				float4 color : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 colorOfTexture : TEXCOORD1;
				float3 worldVertPos : TEXCOORD2;

				float3 worldTangent : TEXCOORD3; //New
				float3 worldNormal : TEXCOORD4; //New
				float3 worldbiNormal :TEXCOORD5; //New
			};


			vertexShaderOut vertexShader(vertexShaderIn input) {
				vertexShaderOut o;
				o.worldVertPos = normalize(mul(unity_ObjectToWorld, input.vertexPos));

				o.worldNormal = normalize(mul(input.normal, unity_ObjectToWorld )); //Bump map, normal as a world normal direction
				o.worldTangent = normalize(mul(unity_ObjectToWorld, input.tangent)); //Bump map, local tangent vector to world tangent of normal
				o.worldbiNormal = normalize(cross(o.worldNormal, o.worldTangent) * input.tangent.w); //Bump map, binormal vector, perpendicular to normal and tangent vectors, multiplying it by tangent, gets it to correct length

				o.colorOfTexture = input.colorOfTexture;
				o.normal = input.normal;
				o.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Always have this, This will project correct vertex "filled siluet shape"

				return o;
			}

			float4 fragmentShader(vertexShaderOut input) : COLOR{

				//General
				float3 lightPosition = normalize(_WorldSpaceLightPos0.xyz);
				float3 cameraDirection = normalize(_WorldSpaceCameraPos);

				//Texture
				float4 colorOfTexture = tex2D(_Texture, input.colorOfTexture.xy);

				//BumMap
				float4 bumpMap = tex2D(_BumpMap, input.colorOfTexture.xy); 
				//Unpack normal 
				float3 localCoords = float3(2.0 * bumpMap.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _bumpStrength;  
				//Normal transpose matrix
				float3x3 local2WorldTranspose = float3x3(input.worldTangent, input.worldbiNormal, input.worldNormal);


				float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose)); //Always have this, will covert local normal vectors to world. Without this light would casted only on predefined side


				//Difuse shading
				float4 diffuseShading = max(0.0, dot(normalDirection, lightPosition)) * _LightColor0 + UNITY_LIGHTMODEL_AMBIENT; // dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

				//Specular shading
				float4 specularMap = tex2D(_SpecularMap, input.colorOfTexture.xy);																												
				float4 specularShading = pow(max(0.0, dot(cameraDirection, reflect(-lightPosition, normalDirection)) + _specularSize), _specularRollof) *  _LightColor0 * specularMap * _specularColor * dot(normalDirection, lightPosition);

				//Skin shine against light. First skin layer of "Oil"
				float4 skinShine = max(0.0, (1 - dot(lightPosition, _WorldSpaceCameraPos))) * max(0.0, dot(normalDirection, lightPosition) * _skinShineColor) *  _skinShinePower;

				//Final
				float4 lightFinal = (diffuseShading * colorOfTexture) + skinShine + specularShading;

				return lightFinal;
			}
				ENDCG
			}

			/*
			//Pass for other lights than directional
				Pass{
					Tags{ "LightMode" = "ForwardAdd" }
					Blend One One
					CGPROGRAM

				//float4 _Color;
				float4 lightDirection;
				float4 _skinShineColor;
				float4 _specularColor;
				float _specularRollof;
				float _specularSize;
				float4 _LightColor0;
				sampler2D _Texture;
				float lightStrength;
				float _skinShinePower;

				#pragma vertex vertexShader
				#pragma fragment fragmentShader

				struct vertexShaderIn {
					float4 vertexPos : POSITION;
					float3 normal : NORMAL;
					float4 colorOfTexture : TEXCOORD0;
				};

				struct vertexShaderOut {
					float4 pos : SV_POSITION;
					float3 normal : NORMAL;
					float4 colorOfTexture : TEXCOORD0;
					float3 worldVertPos : TEXCOORD1;
				};

				vertexShaderOut vertexShader(vertexShaderIn input) {
					vertexShaderOut o;
					o.worldVertPos = normalize(mul(unity_ObjectToWorld, input.vertexPos));
					o.colorOfTexture = input.colorOfTexture;
					o.normal = input.normal;
					o.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Always have this, This will project correct vertex "filled siluet shape"
					return o;
				}

				float4 fragmentShader(vertexShaderOut input) : COLOR{

					//General
					float3 normalDirection = normalize(mul(unity_ObjectToWorld, input.normal)); //Always have this, will covert local normal vectors to world. Without this light would casted only on predefined side
					float3 lightPosition = _WorldSpaceLightPos0.xyz;
					float3 cameraDirection = normalize(_WorldSpaceCameraPos);

					//Calculate strenght of other lights than directional
					if (_WorldSpaceLightPos0.w != 0.0) {
						float distance = length(lightPosition - input.worldVertPos);
						lightStrength = 1/pow(distance, 4); // pow() of 4 could be changed to user accesable variable
						lightPosition = normalize(lightPosition - input.worldVertPos);
					}
					else {
						lightStrength = 1;
					}

					//Difuse shading
					float4 diffuseShading = lightStrength * max(0.0, (dot(normalDirection, lightPosition))) * _LightColor0 ; // dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

					//Specular Shading
					float4 specularShading = lightStrength * pow(max(0.0, dot(cameraDirection, reflect(-lightPosition, normalDirection)) + _specularSize), _specularRollof) * _LightColor0;

					//Skin shine against light. First skin layer of "Oil"
					float4 skinShine = max(0.0, (1 - dot(lightPosition, _WorldSpaceCameraPos))) * max(0.0, dot(normalDirection, lightPosition) * _skinShineColor) * _skinShinePower;

					//Texture
					float4 colorOfTexture = tex2D(_Texture, input.colorOfTexture.xy);

					//Final
					float4 lightFinal = (diffuseShading * colorOfTexture) + skinShine + specularShading;

					return lightFinal ;
				}
					ENDCG
			}
			*/
		}
		Fallback "Diffuse"
		
}

//CG TEXCUBE

// Of screen rendering (camera rendering fx for mirror)

// Unity reflection probe