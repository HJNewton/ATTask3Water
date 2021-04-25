Shader "Unlit/DepthAndEdgeFoam"
{
    Properties
    {
        [HDR] _Colour("Colour", Color) = (1, 1, 1, 1)
        _MainTex("Texture", 2D) = "white" {}

        _DepthFactor("Depth Factor", float) = 1.0
        _DepthStrength("Depth Strength", float) = 1.0
        [HDR] _EdgeColour("Edge Colour", Color) = (1, 1, 1, 1)
        _IntersectionThreshold("Intersection Threshold", Float) = 1
        _IntersectionStrength("Intersection Strength", Float) = 1

        _WaveA("Wave A", Vector) = (1,0,0.5,10)
        _WaveB("Wave B", Vector) = (0,1,0.25,20)
        _WaveC("Wave C", Vector) = (1,1,0.15,10)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight*/
            #pragma fullforwardshadows vertex:vert addshadow alpha


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float4 _Colour;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            float _DepthFactor;
            fixed _DepthStrength;

            float4 _EdgeColour;
            fixed _IntersectionThreshold;
            fixed _IntersectionStrength;

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 gridPoint = v.vertex.xyz;
                float3 tangent = float3(1, 0, 0);
                float3 binormal = float3(0, 0, 1);

                o.vertex.xy += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
                o.vertex.xy += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
                o.vertex.xy += GerstnerWave(_WaveC, gridPoint, tangent, binormal);

                //v.vertex.xyz = gridPoint;

                // Get depth of each vertex based on position
                o.screenPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.screenPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 colour = _Colour * tex2D(_MainTex, i.uv);

                // Get depth
                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
                float depth = sceneZ - i.screenPos.z;

                // Fade with depth
                fixed depthFading = saturate((abs(pow(depth, _DepthStrength))) / _DepthFactor);
                colour *= depthFading;

                // Edge foam line
                fixed intersect = saturate((abs(depth)) / _IntersectionThreshold);
                colour += _EdgeColour * pow(1 - intersect, 4) * _IntersectionStrength;

                return colour;
            }
            ENDCG
        }
    }
}
