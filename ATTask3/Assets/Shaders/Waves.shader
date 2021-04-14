// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Waves"
{
    Properties
    {
        _ColourBase ("Color Base", Color) = (1,1,1,1)
        _ColourHighlight("Color Highlight", Color) = (1,1,1,1)
        _ColourHeight ("Colour Height", Float) = 0.0
        _MaxVariance ("Maximum Variance", Float) = 3.0
        _LerpAmount ("Colour Lerp Amount", Float) = 0.0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _WaveA("Wave A", Vector) = (1,0,0.5,10)
        _WaveB("Wave B", Vector) = (0,1,0.25,20)
        _WaveC("Wave C", Vector) = (1,1,0.15,10)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 color : COLOR;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _ColourBase;
        fixed4 _ColourHighlight;
        float _ColourHeight;
        float _MaxVariance;
        float _LerpAmount;
		float4 _WaveA;
		float4 _WaveB;
		float4 _WaveC;

        float3 GerstnerWave(float4 wave, float3 p, inout float3 tangent, inout float3 binormal)
        {
            float steepness = wave.z;
		    float wavelength = wave.w;
		    float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, p.xz) - c * _Time.y);
			float a = steepness / k;

			tangent += float3(
				-d.x * d.x * (steepness * sin(f)),
				d.x * (steepness * cos(f)),
				-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
				-d.x * d.y * (steepness * sin(f)),
				d.y * (steepness * cos(f)),
				-d.y * d.y * (steepness * sin(f))
			);
			return float3(
				d.x * (a * cos(f)),
				a * sin(f),
				d.y * (a * cos(f))
			);
        }

        void vert(inout appdata_full vertexData) 
        {     
            float3 gridPoint = vertexData.vertex.xyz;
			float3 tangent = float3(1, 0, 0);
			float3 binormal = float3(0, 0, 1);
			float3 p = gridPoint;

			p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
			p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
			p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
			float3 normal = normalize(cross(binormal, tangent));
			vertexData.vertex.xyz = p;	

            float4 worldPos = mul(unity_ObjectToWorld, vertexData.vertex); // Converts all the vertex data to world positions
            float diff = worldPos.y - _ColourHeight; // Calculate the difference between colour height and y pos of vertex
            float factor = saturate(diff/(2*_MaxVariance) + _LerpAmount); // Essentially calculates how much colour to apply

            vertexData.color = lerp(_ColourBase, _ColourHighlight, factor);

            vertexData.normal = normal;
        }
             

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {           
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * IN.color;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = _ColourBase.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
