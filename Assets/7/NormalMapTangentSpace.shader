// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SunQina/NormalMapTangentSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20

    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float4 _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            //_MainTex_ST與_BumpMap_ST是為了得到平鋪與偏移係數

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; //使Unity將頂點的切線方向填充至tangent變量中
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.zw * _BumpMap_ST.xy + _BumpMap_ST.zw;

                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul (rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize (i.lightDir);
                fixed3 tangentViewDir - normalize (i.viewDir);

                //根據i.uv.zw中存儲的normal的紋理座標數據，對_BumpMap這張文裡貼圖進行採樣。
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw); 
                fixed3 tangentNormal;

                //如果在輸入_BumpMap的時候沒有將類型切換為normal map，則此時傳入的數據是rgb。因故，需要對此貼圖進行採樣來獲得圖中的數據。
                //將法向存儲進貼圖時所用的公式，在此處反向計算將其還原成法向量
                tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale; //乘上BumpScale來計算強度
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //計算切線空間下的第三個軸的方向(副切線)
                //saturate函數 : 將結果映射到1~0的範圍中

                //如果輸入時BumpMap的類型已被切換為normal map，則呼叫內置宏
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale; //乘上BumpScale來計算強度
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));


                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb ** allbedo * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                return fixed4 (ambient + diffuse + Specular, 1.0);

            }
            ENDCG
        }
    }
}
