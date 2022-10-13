Shader "SunQian/NewUnlitShader" //���O��/shader�W�r
{
    Properties //�ݩʼƾڦC��
    {
        //�ܶq�W�� ("��ܦW��", �ݩ����� ) = "�q�{��"
        _MainTex ("Texture", 2D) = "white" {}
        //�����ܶq�b�Ҧ��ۦ⾹�����i�H�X��
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100 //Level of details

        Pass //��V�޹D�y���u
        {
            CGPROGRAM //CG�N�X���}�l
            #pragma vertex vert //�i�D�sĶ��vert�N�X��m
            #pragma fragment frag //�i�D�sĶ��frag�N�X��m
            
            #include "UnityCG.cginc" //Unity�ʸ˪�shader API

            struct appdata //�n��appdata�������t�����ǻy�q���ܲ�
            {
                float4 vertex : POSITION; //�w�]�Ȭ��ҫ����I�y��
                float2 uv : TEXCOORD0; // �w�]�Ȭ����z�y��
            };

            struct v2f //�n��v2f�������t�����ǻy�q���ܲ�
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; //�����g�����ܶq�W�١A���i���

             //���I�ۦ⾹
            v2f vert (appdata v)
            {
                v2f o;
                //�y�ЪŶ����ഫ(��v)
                o.vertex = UnityObjectToClipPos(v.vertex);
                // TRANSFORM_TEX �O�@��k�A�ΥH�p��tilling�Poffset���ܶq����v
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //�����ۦ⾹
            fixed4 frag (v2f i) : SV_Target //�N�C����SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG//CG�N�X������
        }
    }
}
