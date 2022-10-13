// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SunQian/20220915/HalfLmabert"
{
     Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader{
    
    pass {
        Tags { "LightMode"="ForwardBase" }   

        CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
      
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            v2f vert (a2v v)
            {
                v2f o;
               //將模型頂點座標，從模型空間轉換到投影空間
               o.pos = UnityObjectToClipPos(v.vertex);
               //將模型法向，從模型空間轉換到投影空間。不使用MVP矩陣，因為法線向量無法使用同個矩陣進行計算，否則會有法線向量並非垂直的問題(系關數學邏輯tengent)
               o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

               return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //聲明fixed3 的世界座標法線，並歸一化
                fixed3 N = normalize(i.worldNormal);
                //聲明fixed3的世界光源方向，並歸一化
                fixed3 L = normalize(_WorldSpaceLightPos0);
                //獲取環境光數據
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = dot ( N , L ) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 color = ambient + diffuse;

                return fixed4 (color, 1.0 );
            }
            ENDCG
        }
    }
}
