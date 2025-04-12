Shader "Unlit/Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Light Intensity", Range(0,1)) = 1
        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shineiness", Range(1,128)) = 16
        _Ambient ("Ambient Strenght", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
                float3 viewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 normalWorld : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _LightInt;
            float4 _LightColor0;
            float4 _SpecColor;
            float _Shininess;
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.viewDir = WorldSpaceViewDir(v.vertex);
                float4 worldPos4 = mul(unity_ObjectToWorld, v.vertex);
                float3 transformNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                o.worldPos = worldPos4.xyz;
                o.normalWorld = transformNormal;


                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 normal = normalize(i.normalWorld);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // lamberd diffuse
                float lambert = max(0, dot(normal, lightDir));

                // specular (blinn-phong)
                float3 viewDir = normalize(i.viewDir);
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float ndotH = max(0,dot(normal, halfVector));
                float specFactor = pow(max(0,ndotH), _Shininess);

                // world Light
                float3 lightColor = _LightColor0.rgb * _LightInt;
                float3 ambient = _Ambient * lightColor;

                float3 diffuse = lambert * lightColor * col.rgb;
                float3 specular = specFactor * lightColor * _SpecColor.rgb;
                float3 finalColor = ambient + diffuse + specular;

                fixed4 color = fixed4(finalColor,1.0);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return color;
            }
            ENDCG
        }
    }
}
