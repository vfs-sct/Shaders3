Shader "Unlit/assignment1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RingColor ("Ring Color", Color) = (1, 0.8, 0.2, 1)
        _RingWidth ("Ring Width", Float) = 0.01
        _RingRadius ("Ring Radius", Float) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        float4 _RingColor;
        float _RingWidth;
        float _RingRadius;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 centeredUV = IN.uv_MainTex - 0.5;
            float radius = length(centeredUV);

            float inner = _RingRadius;
            float outer = inner + _RingWidth;

            // Create a thin ring using smoothstep
            float ringMask = smoothstep(inner, inner + 0.005, radius) - smoothstep(outer, outer + 0.005, radius);

            float3 baseColor = tex2D(_MainTex, IN.uv_MainTex).rgb;
            o.Albedo = lerp(baseColor, _RingColor.rgb, ringMask);
        }
        ENDCG
    }
    FallBack "Diffuse"
}