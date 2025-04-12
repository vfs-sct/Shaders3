
Shader "Unlit/Homework3"
{
    Properties
    {
        _Ring("Ring Thinkness", Range(0,1)) = 0.1
        _SpinSpeedX("Spin SpeedX", Range(0,20)) = 0.1
        _SpinSpeedY("Spin SpeedY", Range(0,20)) = 0.1
    }
    SubShader
    {
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

            struct v2f {
                half3 worldNormal : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            float4x4 RotationX(float angle) {
                float s = sin(angle);
                float c = cos(angle);
                return float4x4(
                    float4(1, 0, 0, 0),
                    float4(0, c, -s, 0),
                    float4(0, s, c, 0),
                    float4(0, 0, 0, 1)
                );
            }
            
            float4x4 RotationY(float angle) {
                float s = sin(angle);
                float c = cos(angle);
                return float4x4(
                    float4(c, 0, s, 0),
                    float4(0, 1, 0, 0),
                    float4(-s, 0, c, 0),
                    float4(0, 0, 0, 1)
                );
            }


            float _Ring;
            float _SpinSpeedX; 
            float _SpinSpeedY; 
            float4 _RingColor;

            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL, appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex); 
                o.uv = v.uv * 2.0 - 1.0;

                float speedX = _Time.y * _SpinSpeedX;
                float speedY = _Time.y * _SpinSpeedY;
                
                float4x4 rotationMatrixX = RotationX(speedX);
                float4x4 rotationMatrixY = RotationY(speedY);
                
                float4x4 combinedRotation = mul(rotationMatrixY, rotationMatrixX);
                
                vertex.xyz = mul(combinedRotation, vertex).xyz;
                normal = normalize(mul(combinedRotation, float4(normal, 0.0)).xyz);


                o.worldNormal = UnityObjectToWorldNormal(normal);
                return o;  
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = length(i.uv);
                if (dist < _Ring)
                {
                    discard;
                }

                // rainbow color
                fixed4 c = 0;
                c.rgb = i.worldNormal * 0.5 + 0.5;
                return c;
            }
            ENDCG
        }
    }
}