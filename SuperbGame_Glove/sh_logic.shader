Shader "SuperbGame_Glove/sh_logic"
{
    Properties
    {
        _LogicCanvas("LogicCanvas", 2D) = "gray" {}
        _PlayerOneJoystick("PlayerOneJoystick", Int) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "shi_logic.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            uniform texture2D _LogicCanvas; // Read, Write.
            uniform int _PlayerOneJoystick;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                int x = floor(IN.localTexcoord[0] * 255.0);
                int y = floor(IN.localTexcoord[1] * 255.0);

                // Load state from texture.
                load_state(_LogicCanvas);

                // Do a different thing depending on the game state.
                updateInput(_PlayerOneJoystick);

				gameState = GAMESTATE_GAME_TITLE;
				prompt.active = true;
				//prompt.cursor = 0;
				prompt.tabCount = 10;
				prompt.tabWidth = 2;
				prompt.rows = 4;
				//prompt.inputBufferLength = 0;

				//prompt.inputBuffer[0] = 'Y';
				//prompt.inputBuffer[1] = 'O';
				//prompt.inputBuffer[2] = 'U';
				//prompt.inputBufferLength = 0;

				records.valid = true;

				records.scores[0] = 1;
				records.scores[1] = 2;
				records.scores[2] = 3;

				records.times[0] = 1;
				records.times[1] = 2;
				records.times[2] = 3;

				records.rooms[0] = 1;
				records.rooms[1] = 2;
				records.rooms[2] = 3;

				records.roomsDiscoveredMask = 0x0;

				records.names[0][0] = 'R';
				records.names[0][1] = 'E';
				records.names[0][2] = 'A';

				records.names[1][0] = 'B';
				records.names[1][1] = 'D';

				records.names[2][0] = 'Y';
				records.names[2][1] = 'E';
				records.names[2][2] = 'S';
				records.names[2][3] = 'U';
                
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
                return save_state(x, y);
            }
            ENDCG
        }
    }
}
