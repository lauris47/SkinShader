// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "My Shaders/Skin Shader 2" {
	Properties{
		_Texture("Texture", 2D) = "White" {}
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
			float4 _LightColor0;
			sampler2D _Texture;
			float lightStrength;

			#pragma vertex vertexShader
			#pragma fragment fragmentShader

			struct vertexShaderIn {
				float4 vertexPos : POSITION;
				float3 normal : NORMAL;
				float4 colorOfTexture : TEXCOORD0;
			};

			struct vertexShaderOut {
				float4 color : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 colorOfTexture : TEXCOORD1;
			};


			vertexShaderOut vertexShader(vertexShaderIn input) {
				vertexShaderOut o;
				o.colorOfTexture = input.colorOfTexture;
				o.normal = input.normal;
				o.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Always have this, This will project correct vertex "filled siluet shape"
				return o;
			}

			float4 fragmentShader(vertexShaderOut input) :COLOR {
				//General
				float3 normalDirection = mul(unity_ObjectToWorld, input.normal); //Always have this, will covert local normal vectors to world. Without this light would casted only on predefined side
				float3 lightPosition = _WorldSpaceLightPos0.xyz;
				float3 cameraDirection = _WorldSpaceCameraPos; // is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

				//Difuse shading
				float4 diffuseShading = max(0.0, dot(normalDirection, _WorldSpaceLightPos0.xyz)) *_LightColor0 + UNITY_LIGHTMODEL_AMBIENT; // dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

				//Specular Shading
				float4 specularShading = pow(max(0.0, dot(cameraDirection, reflect(-lightPosition, normalDirection)) + _specularSize), _specularRollof) *  _LightColor0 * _specularColor;

				//Texture
				float4 colorOfTexture = tex2D(_Texture, input.normal.xy);

				//Final
				float4 lightFinal = (diffuseShading + specularShading) * colorOfTexture;

			return lightFinal;
		}
		ENDCG
		}

			Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM

			float4 _Color;
			float4 lightDirection;
			float4 _specularColor;
			float _specularRollof;
			float _specularSize;
			float4 _LightColor0;
			sampler2D _Texture;
			float lightStrength;

			#pragma vertex vertexShader
			#pragma fragment fragmentShader

			struct vertexShaderIn {
				float4 vertexPos : POSITION;
				float3 normal : NORMAL;
				float4 colorOfTexture : TEXCOORD0;
			};

			struct vertexShaderOut {
				float4 color : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 colorOfTexture : TEXCOORD1;
			};


			vertexShaderOut vertexShader(vertexShaderIn input) {
				vertexShaderOut o;
				o.colorOfTexture = input.colorOfTexture;
				o.normal = input.normal;
				o.pos = mul(UNITY_MATRIX_MVP, input.vertexPos); //Always have this, This will project correct vertex "filled siluet shape"
				return o;
			}

			float4 fragmentShader(vertexShaderOut input) : COLOR{
				float3 normalDirection = normalize(mul(unity_ObjectToWorld, input.normal)); //Always have this, will covert local normal vectors to world. Without this light would casted only on predefined side

				//General
				float3 lightPosition = normalize(_WorldSpaceLightPos0.xyz);
				float3 cameraDirection = normalize(_WorldSpaceCameraPos);

				//Difuse shading
				float4 diffuseShading = max(0.0, dot(normalDirection, lightPosition)) * _LightColor0 + UNITY_LIGHTMODEL_AMBIENT; // dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)

				//Specular Shading
				float4 specularShading = pow(max(0.0, dot(cameraDirection, reflect(-lightPosition, normalDirection)) + _specularSize), _specularRollof) *  _LightColor0 * _specularColor;

				//Texture
				float4  colorOfTexture = tex2D(_Texture, input.normal.xy);

				//Final
				float4 lightFinal = (diffuseShading + specularShading) ;

				return lightFinal;
			}
				ENDCG
			}


			//Pass for other lights than directional		
				Pass{
					Tags{ "LightMode" = "ForwardAdd" }
					Blend One One
					CGPROGRAM

				float4 _Color;
				float4 lightDirection;
				float4 _specularColor;
				float _specularRollof;
				float _specularSize;
				float4 _LightColor0;
				sampler2D _Texture;
				float lightStrength;

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
						lightStrength = 1/pow(distance, 5);
						lightPosition = normalize(lightPosition - input.worldVertPos);
					}
					else {
						lightStrength = 1;
					}

					//Difuse shading
					float4 diffuseShading = lightStrength * max(0.0, (dot(normalDirection, lightPosition))) * _LightColor0 ; // dot() will return higher value if angle is smallest, that is why objects are lit the most, in straighest line to the vertex point (they have closest to 0 angle, which will produce closest to 1 result)
					/*
					//Specular Shading
					float4 specularShading = lightStrength * pow( max(0.0, dot(cameraDirection, reflect(-lightPosition, normalDirection)) + _specularSize), _specularRollof) * _LightColor0;

					//Texture
					float4 colorOfTexture = tex2D(_Texture, input.normal.xy);
					*/
					//Final
					float4 lightFinal = diffuseShading;

					return lightFinal;
				}
					ENDCG
			}

		}
		Fallback "Diffuse"
}

//CG TEXCUBE

// Of screen rendering (camera rendering fx for mirror)

// Unity reflection probe