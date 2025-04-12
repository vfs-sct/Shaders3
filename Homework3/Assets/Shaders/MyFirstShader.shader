Shader "Custom/UnlitRing"
{
    Properties
    {
        _InnerRadius ("Inner Radius", Range(0, 1)) = 0.3
        _OuterRadius ("Outer Radius", Range(0, 1)) = 0.5
        _RingColor ("Ring Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            float _InnerRadius;
            float _OuterRadius;
            fixed4 _RingColor;
             
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2.0 - 1.0; // center UV around (0,0)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = length(i.uv);
                if (dist < _InnerRadius || dist > _OuterRadius)
                    discard;

                return _RingColor;
            }
            ENDCG
        }
    }
}
