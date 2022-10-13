// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "20221013/SingleTexture"
{
    Properties
    {
       _Color ("Color Tint" ,  Color ) = (1,1,1,1)
       _MainTex ("Main Tex" , 2D) = "white" {}
       _Specular ("Specular" , Color) = (1,1,1,1)
       _Gloss ("Gloss" , Range(8.0 , 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            //LightMode標籤是pass標籤的一種，用於定義此pass在流水線中的角色

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            //為了調用unity內置的一些數據變量，須包含特定的cginc文件

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;
            //初始化
            //_MinaTex_ST的ST代表的是scale和transform，此變量用於存儲材質貼圖的Tilling和Offset 

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;

                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //這裡將紋理座標texcoord與_MainTex_ST中存儲的Tilling與Offset相乘相加，以達到紋理貼圖的變換。
                //也可以直接調用Unity內置宏 o.uv = TRANFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_TARGET {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize (UnityWorldSpaceLightDir(i.worldPos));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                //將貼圖與UV傳入，並與Color相乘，以將貼圖的色彩數據貼到物體上。

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //傳遞環境光數據，並與貼圖相乘

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                //計算物體本身發散出的光(由世界光與自身顏色決定)

                fixed3 viewDir = normalize (UnityWorldSpaceViewDir (i.worldPos));
                fixed3 halfDir = normalize (worldLightDir + viewDir);
                //獲取攝像機與世界光的折半方向，這是用於計算布林馮的高光反射

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal,halfDir)), _Gloss);
                //pow函數的意思為 = 以x為底，x的y次方
                //布林馮模型有三個層次:即黑、白、灰。pow函數即是把灰色的部分依照程序員所希望的去變黑，高光變小
                //由於每個像素都乘與其自身，因此黑*黑仍為黑，白*白仍為白
                //灰色部分由於都是0.幾的小數，因此會越乘越小，部分像素就會變黑，白色部分也縮小
                //從而可以透過pow函數去控制高光範圍

                return fixed4(ambient + specular + diffuse , 1.0);
            }

            ENDCG
            
        }
    }
}
