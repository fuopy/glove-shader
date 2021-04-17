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
				float4 redColor = { 255, 0, 0, 0 };
				float4 greenColor = { 0, 255, 0, 0 };
				float4 blackColor = { 0, 0, 0, 0 };
				float4 blueColor = { 0, 0, 255, 0 };

				//int iter;
				
				// Setup: Load values.
				//p1.x = 0;
				//p1.y = 0;
				//p1.active = 1;
				//p1.direction = 0;
				//p1.frame = 0;

				// Cleanup: Store values.

				// Draw Background.
				//finalColor = draw_background(x, y, _BackgroundImage);
				//if (finalColor[0] > .5) return finalColor;
				//scrollx = -31;


				// Draw Font.
				//finalColor = draw_string(x, y, 0, 16, levelNames[0], _Font);
				//if (finalColor[0] > .5) return finalColor;

				// Draw some 69's.
				//finalColor = draw_integer(x, y, 0, 32, scrollx, _Font);
				//if (finalColor[0] > .5) return finalColor;

				//finalColor = draw_integer(x, y, 0, 0, exits[0].active ? 1 : 2, _Font);
				//if (finalColor[0] > .5) return finalColor;
				//finalColor = draw_integer(x, y, 0, 8, exits[1].active ? 1 : 2, _Font);
				//if (finalColor[0] > .5) return finalColor;
				//finalColor = draw_integer(x, y, 0, 16, exits[2].active ? 1 : 2, _Font);
				//if (finalColor[0] > .5) return finalColor;
				//finalColor = draw_integer(x, y, 0, 24, exits[3].active ? 1 : 2, _Font);
				//if (finalColor[0] > .5) return finalColor;
				
				//gameState = GAMESTATE_HISCORE_INPUT;

				//finalColor = draw_string(x, y, 0, 0, levelNames[0], _Font);
				//finalColor = draw_character(x, y, 0, 0, 'a', _Font);
				//if (true)
					//return finalColor;

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
					finalColor = titleDraw(x, y, _GameSprites, _Font, _TitleImage);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_GAME_LEVELNAME:
					finalColor = levelNameDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_GAME_LOOP:
					finalColor = gameDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_GAME_OVER:
					// Draw "Game Over".
					finalColor = gameOverDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					finalColor = gameEndDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_GAME_COMPLETE:
					// Draw "Game Complete".
					finalColor = gameCompleteDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					finalColor = gameEndDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_HISCORE_INPUT:
					finalColor = hiscoreInputDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_MAIN_MENU:
					finalColor = mainMenuDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				case GAMESTATE_HISCORE_VIEW:
					finalColor = hiscoreViewDraw(x, y, _GameSprites, _Font);
					if (finalColor[0] > .5) return finalColor;
					break;
				}
				
				return blackColor;
			}
			ENDCG
		}
	}
}
