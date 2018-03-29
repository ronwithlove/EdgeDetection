// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "single texture1" {
	Properties{
		_MainTex("Texture Image", 2D) = "white" {} //一个2D纹理属性，我们叫_MainTex,Unity中的纹理图像，使用默认的内嵌white纹理，也可以选着 black,gray,bump
	_YTex("Y Tex", 2D) = "white" {}
	_SecondTex("ScreenShoot", 2D) = "white" {}
	_AmountBG("Amount BG", Range(0.0, 1.0)) = 0.172
	}
		SubShader{
		Pass{
		CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

	uniform sampler2D _MainTex;	//一个uniform变量，对应上面属性，一个小的整数来特质一个纹理单元，纹理图像被帮到他身上，
	uniform float4 _MainTex_ST;//

	uniform sampler2D _YTex;	//一个uniform变量，对应上面属性，一个小的整数来特质一个纹理单元，纹理图像被帮到他身上，
	uniform float4 _YTex_ST;//


	uniform sampler2D _SecondTex;
	fixed _AmountBG;

	struct vertexInput {
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD0;//顶点输入部分 比起最简单的Shader,多出了一个TEXCOORD0

	};
	struct vertexOutput {
		float4 pos : SV_POSITION;
		float4 tex : TEXCOORD0; //片段输入部分，也多了一个TEXCOORD0
	};

	fixed4 OverlayBlendMode(fixed4 basePixel, fixed4 bgPixel) {

		if (abs(basePixel.r - bgPixel.r)>_AmountBG || abs(basePixel.g - bgPixel.g)>_AmountBG || abs(basePixel.b - bgPixel.b)>_AmountBG) {
			basePixel.r = 1;
			basePixel.g = 1;
			basePixel.b = 1;
			return basePixel;
		}
		else {
			return 0;
		}

	}

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		output.tex = input.texcoord;//在顶点shader里通过顶点把TEXCOORD0传给片段，（啥都没做？）
		output.pos = UnityObjectToClipPos(input.vertex); //返回POSITION给片段，100年不变
		return output;
	}


	float4 frag(vertexOutput input) : COLOR
	{
	//	fixed4 bgTex = tex2D(_MainTex,   _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);
		//fixed4 bgTex = tex2D(_MainTex,    _MainTex_ST.zw);
		fixed4 bgTex = tex2D(_MainTex,   _MainTex_ST.xy * input.tex.xy + _MainTex_ST.wz);
		fixed4 secTex = tex2D(_SecondTex, input.tex.xy);
		fixed4 mixOne= OverlayBlendMode(secTex, bgTex);

		bgTex = tex2D(_YTex, _YTex_ST.xy * input.tex.xy + _YTex_ST.wz);
		secTex = tex2D(_SecondTex, input.tex.xy);
		fixed4 mixTwo = OverlayBlendMode(secTex, bgTex);

		return mixOne+mixTwo;
	}

		ENDCG
	}
	}
		Fallback "Unlit/Texture"
}