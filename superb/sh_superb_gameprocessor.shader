Shader "superb/sh_superb_gameprocessor_update"
{
	Properties
	{
		_GameProcessorCanvas("GameProcessorCanvas", 2D) = "gray" {}
		_InputBufferCanvas("InputBufferCanvas", 2D) = "gray" {}
		_PlayerOneJoystick("PlayerOneJoystick", Int) = 0
		_ExternalClockTick("ExternalClockTick", Int) = 65536
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#include "shi_superb_logic.hlsl"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag
			#pragma target 5.0

			uniform texture2D _GameProcessorCanvas; // Read, Write.
			uniform texture2D _InputBufferCanvas; // Read Only
			uniform int _PlayerOneJoystick;
			uniform int _ExternalClockTick;

			float4 frag(v2f_customrendertexture IN) : COLOR
			{
				int x = floor(IN.localTexcoord[0] * 255.0);
				int y = floor(IN.localTexcoord[1] * 255.0);

				// Load state from texture.
				load_state(_GameProcessorCanvas);
				//load_upper_state(_InputBufferCanvas);

				// If the clock has ticked, continue the game.
				// TODO: Clock driven by UDON.
				//if (logicClockTick != _ExternalClockTick) // old: clockTick (upper val)
				//{
					logicClockTick = _ExternalClockTick;

					// Do a different thing depending on the game state.
					updateInput(_PlayerOneJoystick);
					//updateInput(nextInputState);
				
					// Run one time.
					//if (!p1.active)
					//{
					//	displayGame();
					//}
					//gameState = GAMESTATE_GAME_TITLE;
				
					// Change update logic based on game state.
					switch (gameState)
					{
					case GAMESTATE_GAME_TITLE:
						titleUpdate();
						break;
					case GAMESTATE_GAME_LEVELNAME:
						levelNameUpdate();
						break;
					case GAMESTATE_GAME_LOOP:
						gameUpdate();
						break;
					case GAMESTATE_GAME_PRELOOP:
						gameState = GAMESTATE_GAME_LOOP;
						break;
					case GAMESTATE_GAME_OVER:
						// Draw "Game Over".
						gameEndUpdate();
						break;
					case GAMESTATE_GAME_COMPLETE:
						// Draw "Game Complete".
						gameEndUpdate();
						break;
					case GAMESTATE_HISCORE_INPUT:
						hiscoreInputUpdate();
						break;
					case GAMESTATE_MAIN_MENU:
						mainMenuUpdate();
						break;
					case GAMESTATE_HISCORE_VIEW:
						hiscoreViewUpdate();
						break;
					}
				//}
				// Update
				return save_state(x, y);
			}
			ENDCG
		}
	}
}
