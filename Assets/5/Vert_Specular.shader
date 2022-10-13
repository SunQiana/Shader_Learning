// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "SunQian/20220916/Vert_Specular"
{
    Properties
    {
        _Diffuse ("Diffuse" , Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        //LightMode是標籤的一種，用於定義此pass在Unity光照流水線中的角色。
        //只有定義了正確的LightMode，才能獲取對應的光照變量如_LightColor0
        Tags { "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
               float4 pos : SV_POSITION;
               fixed3 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f o;
               o.pos = UnityObjectToClipPos(v.vertex);

               //獲取環境光參數
               float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

               float3 worldNormal = normalize(mul(v.normal , (float3x3)unity_WorldToObject));
               float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

               float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

               //獲取反射光方向
               float3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
               //獲取相機方向，因為不是每個位置都會有反射光，所以須考量相機方向(相機位置減物體位置，獲取向量後歸一化)
               float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

               //pow函數：使對象乘以 指定次數 的自身
               //由於gloss(光澤度)決定了高光程度，因此將其乘以指定次數，越高者可以獲得越高程度的高光
               float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)),_Gloss);

               o.color = ambient + diffuse + specular;

               return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4 (i.color, 1.0);
            }
            ENDCG
        }
    }
}
