Shader "Learning/20220605"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //格式： name ("display name" , type) = 值
        //name == 該屬性的名稱， Unity中以下划線開始(_name)。
        //display name == 在unity的inspator中的名字
        //type == 此屬性的類型 (各種類型與其後綴選項在下方列舉)
        //值 == 此屬性的默認值

        // type(屬性)的各項列舉
        // 2D：2D紋理屬性；Rect：
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightingMode" = "ForwardBase" }
        //格式：{[Tags], [Commonstate], Pass{}}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            #include "UnityCG.cginc" 
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;  
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; //存取模型法線
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wNormal : TEXCOORD1; //世界座標系下的法線，要傳給片元以做光照計算
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //計算頂點法線，插值後，傳遞給片元
                o . wNormal = UnityObjectToWorldNormal( v . normal );  //模型法線座標轉換為世界法線座標
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 L = normalize(_WorldSpaceLightPos0);
                float3 N =normalize( i . wNormal);

                float halfLam = dot ( L, N ) * 0.5 + 0.5;

                float3 diffLight = halfLam * _LightColor0.rgb;

                // sample the texture
                fixed4 diffColor = fixed4(diffLight.rgb, 1); //float3轉fixed4
                fixed4 col = tex2D(_MainTex, i.uv);

                return col * diffColor;
            }
            ENDCG
        }
    }
}
