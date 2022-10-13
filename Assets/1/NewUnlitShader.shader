Shader "SunQian/NewUnlitShader" //類別項/shader名字
{
    Properties //屬性數據列表
    {
        //變量名稱 ("顯示名稱", 屬性類型 ) = "默認值"
        _MainTex ("Texture", 2D) = "white" {}
        //此些變量在所有著色器中都可以訪問
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100 //Level of details

        Pass //渲染管道流水線
        {
            CGPROGRAM //CG代碼的開始
            #pragma vertex vert //告訴編譯器vert代碼位置
            #pragma fragment frag //告訴編譯器frag代碼位置
            
            #include "UnityCG.cginc" //Unity封裝的shader API

            struct appdata //聲明appdata巨集中含有哪些語義指示符
            {
                float4 vertex : POSITION; //預設值為模型頂點座標
                float2 uv : TEXCOORD0; // 預設值為紋理座標
            };

            struct v2f //聲明v2f巨集中含有哪些語義指示符
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; //引擎寫死的變量名稱，不可更改

             //頂點著色器
            v2f vert (appdata v)
            {
                v2f o;
                //座標空間的轉換(投影)
                o.vertex = UnityObjectToClipPos(v.vertex);
                // TRANSFORM_TEX 是一方法，用以計算tilling與offset兩變量的投影
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //片元著色器
            fixed4 frag (v2f i) : SV_Target //將顏色丟到SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG//CG代碼的結束
        }
    }
}
