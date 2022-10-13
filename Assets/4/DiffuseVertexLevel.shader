// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SunQian/20220915/DiffuseVertexLevel"
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

      v2f  vert(a2v v)
      {
        v2f o;
        //從模型空間轉換為投影空間
        o.pos = UnityObjectToClipPos (v.vertex);

        //獲取環境光參數(待會要跟計算結果相加)
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

        //將法線從模型空間轉換為世界空間
        fixed3 worldNormal = normalize(mul (v.normal, (float3x3)unity_WorldToObject));
        //獲取世界光方向
        fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
        //總計算
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate (dot (worldNormal,worldLight));
        //saturate函數用於將結果限制在0~1之間範圍。

        //將前面所求的環境光參數，與運算結果的diffuse參數相加。
        o.color = ambient + diffuse;
        
        return o;
      }

      fixed4  frag(v2f i):SV_Target
      {
        return fixed4 (i.color, 1.0);
      }
      ENDCG
    }
  }
}

