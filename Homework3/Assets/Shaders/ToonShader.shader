Shader "Unlit/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0.5, 0.65, 1, 1)
        _AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
        _SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
        _Glossiness("Glossiness", Float) = 32
        _RimThreshold("Rim Threshold", Range(0,1)) = 0.1
        _RimColor("Rim Color", Color) = (0.9,0.9,0.9,1)
    }
    SubShader
    {
        Tags 
        {
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir: TEXCOORD1;
            };

            float4 _Color;
            float4 _AmbientColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Glossiness;
            float4 _SpecularColor;
            float _RimThreshold;
            float4 _RimColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float nl = dot(_WorldSpaceLightPos0, normal);
                float lightIntensity = smoothstep(0,0.03,nl);
                float4 light = lightIntensity * _LightColor0;

                float3 viewDir = normalize(i.viewDir);

                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float NdotH = dot(normal, halfVector);
                float specularIntensity = pow(NdotH * lightIntensity, _Glossiness);
                float specularIntensitySmooth = smoothstep(0.005,0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _SpecularColor;

                float rimDot = 1 - max(dot(viewDir, normal),0);
                float rimIntensity = smoothstep(_RimThreshold - 0.05, _RimThreshold + 0.05, rimDot);
                float4 rim = rimIntensity * _RimColor;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col * _Color * (light + _AmbientColor + specular + rim);
            }
            ENDCG
        }
    }
}
