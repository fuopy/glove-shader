Shader "SuperbGame_Glove/sh_render"
{
	Properties
	{
		_LogicCanvas("LogicCanvas", 2D) = "gray" {}

		_GameSprites("GameSprites", 2D) = "gray" {}
		_Font("Font", 2D) = "gray" {}
		_TitleImage("TitleImage", 2D) = "gray" {}

		_TestNumber("TestNumber", Int) = 0
		_TestNumber2("TestNumber2", Int) = 0
		_TestNumber3("TestNumber3", Int) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#include "shi_render.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment fragr
			#pragma target 5.0

			uniform texture2D _LogicCanvas; // Read Only.
			uniform texture2D _GameSprites;
			uniform texture2D _Font;
			uniform texture2D _TitleImage;

			uniform int _TestNumber; // A debugging number, shown in blue.
			uniform int _TestNumber2; // A debugging number, shown in green.
			uniform int _TestNumber3; // A debugging number, shown in red.

			float4 fragr(v2f_customrendertexture IN) : COLOR
			{
				static const float IMAGE_WIDTH = 128.0;
				static const float IMAGE_HEIGHT = 64.0;
				int x = floor(IN.localTexcoord[0] * IMAGE_WIDTH);
				int y = floor(IN.localTexcoord[1] * IMAGE_HEIGHT);
				
				load_state(_LogicCanvas);

				// Update with the color Blue.
				float4 finalColor = { 0, 0, 0, 0 };

				// Draw the debugging number on top of everything.
				if (_TestNumber > 0)
				{
					int xPos = 0;
					int yPos = 56;
					finalColor = draw_integer(x, y, xPos, yPos, _TestNumber, _Font);
					if (finalColor[0] > .5)
					{
						return blueColor;
					}
				}
				if (_TestNumber2 > 0)
				{
					int xPos = 0;
					int yPos = 48;
					finalColor = draw_integer(x, y, xPos, yPos, _TestNumber2, _Font);
					if (finalColor[0] > .5)
					{
						return greenColor;
					}
				}
				if (_TestNumber3 > 0)
				{
					int xPos = 0;
					int yPos = 40;
					finalColor = draw_integer(x, y, xPos, yPos, _TestNumber3, _Font);
					if (finalColor[0] > .5)
					{
						return redColor;
					}
				}
				
				// Change update logic based on game state.
				switch (gameState)
				{
				case GAMESTATE_GAME_TITLE:
					PIXEL(finalColor, titleDraw(x, y, _GameSprites, _Font, _TitleImage));
					break;
				case GAMESTATE_GAME_LEVELNAME:
					PIXEL(finalColor, levelNameDraw(x, y, _GameSprites, _Font));
					break;
				case GAMESTATE_GAME_LOOP:
					PIXEL(finalColor, gameDraw(x, y, _GameSprites, _Font));
					break;
				case GAMESTATE_GAME_OVER:
					// Draw "Game Over".
					PIXEL(finalColor, gameOverDraw(x, y, _GameSprites, _Font));
					PIXEL(finalColor, gameEndDraw(x, y, _GameSprites, _Font));
					break;
				case GAMESTATE_GAME_COMPLETE:
					// Draw "Game Complete".
					PIXEL(finalColor, gameCompleteDraw(x, y, _GameSprites, _Font));
					PIXEL(finalColor, gameEndDraw(x, y, _GameSprites, _Font));
					break;
				case GAMESTATE_HISCORE_INPUT:
					PIXEL(finalColor, hiscoreInputDraw(x, y, _GameSprites, _Font));
					break;
				case GAMESTATE_MAIN_MENU:
					PIXEL(finalColor, mainMenuDraw(x, y, _GameSprites, _Font));
					break;
				case GAMESTATE_HISCORE_VIEW:
					PIXEL(finalColor, hiscoreViewDraw(x, y, _GameSprites, _Font));
					break;
				}

				PIXEL(finalColor, draw_filledrect(x, y, 2, 2, 10, 10, redColor));
				
				return blackColor;
			}
			ENDCG
		}
	}
}
