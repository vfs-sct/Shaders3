Shader "Custom/Stripes"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Width ("Width", Range(0.0, 100.0)) = 0.2
        _StripeGap ("StripeGap", Range(0.0, 100.0)) = 0.1
        _Speed ("Speed", Range(0.0, 100.0)) = 1.0
        _Tilt ("Tilt", Range(0.0, 100.0)) = 0.7
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Width;
        float _StripeGap;
        float _Speed;
        float _Tilt;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // move the stripes down
            float tilt = IN.worldPos.y + (IN.worldPos.x) * _Tilt;
            float worldPosY = tilt + (_Speed * _Time.y);  

            // make stripes
            for (float i = 0; i < 10; i+= _Width)
            {
                clip (frac((worldPosY + i)) -_StripeGap); 
            }

            // change color
            if (floor(_Time.y) % 4 == 3)
            {
                _Color = int4(1, 1, 1, 1);
            }
            else if (floor(_Time.y) % 4 == 2)
            {
                _Color = int4(1, 0, 0, 1);
            }
            else if (floor(_Time.y) % 4 == 1)
            {
                _Color = int4(0, 1, 0, 1);
            }

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
