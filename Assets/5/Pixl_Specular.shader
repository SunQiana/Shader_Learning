// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "SunQian/20220916/Pixl_Specular"
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
               float3 worldNormal : TEXCOORD0;
               float3 worldPos : TEXCOORD1;
            };

            v2f vert (a2v v)
            {
                v2f o;
               o.pos = UnityObjectToClipPos(v.vertex);
              
               o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
               o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

               return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //聲明
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb *saturate(dot(worldNormal, worldLightDir));

                float3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                //獲取相機視角方向的向量，並歸一化
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)),_Gloss);

                return float4 (ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
