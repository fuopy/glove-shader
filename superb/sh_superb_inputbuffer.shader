Shader "superb/sh_superb_inputbuffer_update"
{
	Properties
	{
		_InputBufferCanvas("InputBufferCanvas", 2D) = "gray" {}
		_Sprites("Sprites", 2D) = "gray" {}
		_Font("Font", 2D) = "gray" {}
		_CurrentNetworkFrame("CurrentNetworkFrame", Int) = 0
		_IsMaster("IsMaster", Int) = 0

		_NetworkClock("NetworkClock", Int) = 0

		_State_00("State_00", Int) = 0
		_State_01("State_01", Int) = 0
		_State_02("State_02", Int) = 0
		_State_03("State_03", Int) = 0
		_State_04("State_04", Int) = 0
		_State_05("State_05", Int) = 0
		_State_06("State_06", Int) = 0
		_State_07("State_07", Int) = 0
		_State_08("State_08", Int) = 0
		_State_09("State_09", Int) = 0
		_State_10("State_10", Int) = 0
		_State_11("State_11", Int) = 0
		_State_12("State_12", Int) = 0
		_State_13("State_13", Int) = 0
		_State_14("State_14", Int) = 0
		_State_15("State_15", Int) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#include "shi_superb_uppershared.hlsl"
			#include "shi_superb_input.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag
			#pragma target 5.0

			uniform texture2D _InputBufferCanvas; // Read, Write.
			uniform texture2D _Sprites;
			uniform texture2D _Font;

			uniform int _CurrentNetworkFrame;
			uniform int _IsMaster;

			uniform int _NetworkClock;

			uniform int _State_00;
			uniform int _State_01;
			uniform int _State_02;
			uniform int _State_03;
			uniform int _State_04;
			uniform int _State_05;
			uniform int _State_06;
			uniform int _State_07;
			uniform int _State_08;
			uniform int _State_09;
			uniform int _State_10;
			uniform int _State_11;
			uniform int _State_12;
			uniform int _State_13;
			uniform int _State_14;
			uniform int _State_15;

			static const int frameNumberString[16] = { 'F', 'r', 'a', 'm', 'e', ' ', '#', ':', ' ', '\0', ' ', ' ', ' ', ' ', ' ', '\0' };
			static const int buttonsString[16] = { 'B', 'u', 't', 't', 'o', 'n', 's', ':', ' ', '\0', ' ', ' ', ' ', ' ', ' ', '\0' };

			float4 draw_input(int inputBuffer, int index, int x, int y)
			{
				float4 pressedColor = { 1, 0, 1, 0 };
				float4 notPressedColor = { 0, 0, 0, 0 };

				inputBuffer = 0xff;

				int localX = (index * 6) - x;

				if ((localX == 0) && (inputBuffer & 0x01)) return pressedColor; // A button
				if ((localX == 1) && (inputBuffer & 0x02)) return pressedColor; // B button
				if ((localX == 2) && (inputBuffer & 0x04)) return pressedColor; // Left button
				if ((localX == 3) && (inputBuffer & 0x08)) return pressedColor; // Right button
				if ((localX == 4) && (inputBuffer & 0x10)) return pressedColor; // Up button
				if ((localX == 5) && (inputBuffer & 0x20)) return pressedColor; // Down button
				return notPressedColor;
			}

			float4 draw_input_data(int x, int y, int dx, int dy, int data, texture2D sprites, texture2D font)
			{
				int sprite_0 = (data & 1) ? 0 : 32 + 0;
				int sprite_1 = (data & 2) ? 1 : 32 + 1;
				int sprite_2 = (data & 4) ? 2 : 32 + 2;
				int sprite_3 = (data & 8) ? 3 : 32 + 3;
				int sprite_4 = (data & 16) ? 4 : 32 + 4;
				int sprite_5 = (data & 32) ? 5 : 32 + 5;

				float4 finalColor = { 0, 0, 0, 0 };
				int destX = dx;
				int destY = dy;
				PIXEL(finalColor, draw_string(x, y, destX, destY, buttonsString, font))

				PIXEL(finalColor, draw_sprite(x, y, destX + 0, destY, sprite_0, sprites))
				PIXEL(finalColor, draw_sprite(x, y, destX + 8, destY, sprite_1, sprites))
				PIXEL(finalColor, draw_sprite(x, y, destX + 16, destY, sprite_2, sprites))
				PIXEL(finalColor, draw_sprite(x, y, destX + 24, destY, sprite_3, sprites))
				PIXEL(finalColor, draw_sprite(x, y, destX + 32, destY, sprite_4, sprites))
				PIXEL(finalColor, draw_sprite(x, y, destX + 40, destY, sprite_5, sprites))

				int frameNumber = (data >> 6);
				destX += 48 + 8;
				PIXEL(finalColor, draw_string(x, y, destX, destY, frameNumberString, font))
				PIXEL(finalColor, draw_integer(x, y, destX, destY, frameNumber, font))

				return finalColor;
			}

			float4 draw_input_data_mini(int x, int y, int dx, int dy, int data, texture2D sprites, texture2D font)
			{
				float4 finalColor = { 0, 0, 0, 0 };

				int a_button = (data & 1) ? true : false;
				int b_button = (data & 2) ? true : false;
				int left_button = (data & 4) ? true : false;
				int right_button = (data & 8) ? true : false;
				int up_button = (data & 16) ? true : false;
				int down_button = (data & 32) ? true : false;

				if (a_button) PIXEL(finalColor, draw_pixel(x, y, dx, dy));
				if (b_button) PIXEL(finalColor, draw_pixel(x, y, dx+1, dy));
				if (left_button) PIXEL(finalColor, draw_pixel(x, y, dx+2, dy));
				if (right_button) PIXEL(finalColor, draw_pixel(x, y, dx+3, dy));
				if (up_button) PIXEL(finalColor, draw_pixel(x, y, dx+4, dy));
				if (down_button) PIXEL(finalColor, draw_pixel(x, y, dx+5, dy));

				return finalColor;
			}

			#define FRAMENUM(x)(x>>6)

			// Used for finding the lowest next frame to process.
			void checkStateHelper(int state, inout int lowestFrame, inout int stateValue)
			{
				int frame = FRAMENUM(state);
				if ((frame < lowestFrame) && (frame > FRAMENUM(nextInputState)))
				{
					lowestFrame = frame;
					stateValue = state;
				}
			}

			void processMostRecentFrameData()
			{
				// Process frames in order.
				int lowestFrame = 65536;
				int stateValue = nextInputState; // Default to previous input state.

				// Get the lowest next frame.
				checkStateHelper(_State_00, lowestFrame, stateValue);
				checkStateHelper(_State_01, lowestFrame, stateValue);
				checkStateHelper(_State_02, lowestFrame, stateValue);
				checkStateHelper(_State_03, lowestFrame, stateValue);
				checkStateHelper(_State_04, lowestFrame, stateValue);
				checkStateHelper(_State_05, lowestFrame, stateValue);
				checkStateHelper(_State_06, lowestFrame, stateValue);
				checkStateHelper(_State_07, lowestFrame, stateValue);
				checkStateHelper(_State_08, lowestFrame, stateValue);
				checkStateHelper(_State_09, lowestFrame, stateValue);
				checkStateHelper(_State_10, lowestFrame, stateValue);
				checkStateHelper(_State_11, lowestFrame, stateValue);
				checkStateHelper(_State_12, lowestFrame, stateValue);
				checkStateHelper(_State_13, lowestFrame, stateValue);
				checkStateHelper(_State_14, lowestFrame, stateValue);
				checkStateHelper(_State_15, lowestFrame, stateValue);

				if (_IsMaster && (upperNetClock != _NetworkClock))
				{
					//upperNetClock = _NetworkClock;
					// Only advance if we're on that frame now.
					//if (currentFrame >= lowestFrame)
					//{
						mostRecentProcessedFrame = lowestFrame;
						nextInputState = stateValue;
					//}
				}
				else
				{
					int nextFrame = lowestFrame;
					bool nextFrameExists = (nextFrame != 65536);
					int timeUntilNextInputFrame = (nextFrame - currentFrame);
					int isNextFrameReady = (nextFrame == currentFrame);

					// Only do stuff if we have data in the buffer.
					if (nextFrameExists)
					{
						// If we're 60 frames behind, enter CATCH_UP mode.
						if (timeUntilNextInputFrame > 180)
						{
							caughtUp = 0; // Enter CATCH_UP mode.
						}
						// If we're in CATCH_UP mode, immediately teleport to the next frame.
						if (!caughtUp)
						{
							// Advance frame because we got to the next one. Update the input, too.
							currentFrame = nextFrame;
							mostRecentProcessedFrame = nextFrame;
							nextInputState = stateValue;

							caughtUp = 1; // Exit CATCH_UP mode.
						}
						// If we're not in CATCH_UP, advance frames normally.
						else
						{
							// Only advance if we're on that frame now.
							if (isNextFrameReady)
							{
								// Advance frame because we got to the next one. Update the input, too.
								mostRecentProcessedFrame = nextFrame;
								nextInputState = stateValue;
							}
						}
						// Advance frame whenever we have data.
						clockTick = (clockTick == SIGNAL_ON) ? SIGNAL_OFF : SIGNAL_ON;
						currentFrame++;
					}
				}
			}

			// Master: Input clock driven by shader.
			// Peer: Input clock driven by data available.

			// Let's make them the same, now that I think about it.

			// Input buffer drives the clock on the other textures. Let's start by just making
			// the clock variable.
			float4 frag(v2f_customrendertexture IN) : COLOR
			{
				int x = floor(IN.localTexcoord[0] * 255.0);
				int y = floor(IN.localTexcoord[1] * 255.0);

				load_upper_state(_InputBufferCanvas);

				// Test.
				upperNetClock = _NetworkClock;

				// Tick the clock.

				// Advance the frame.
				if (_IsMaster)
				{
					clockTick = (clockTick == SIGNAL_ON) ? SIGNAL_OFF : SIGNAL_ON;
					currentFrame = _CurrentNetworkFrame;
				}

				// Next input state is the most recent frame data.
				processMostRecentFrameData();

				// Update with the color Red.
				float4 finalColor = {1, 0, 0, 0};
				float4 orangeColor = { 1, .5, 0, 0 };
				float4 blackColor = { 0, 0, 0, 0 };
				float4 blueColor = { 0, 0, 1, 0 };

				// If we are the top-left pixel, return ORANGE.
				if (x == y) {
					finalColor = orangeColor;
				}

				// TODO: Use load/save state paradigm. This is de way.

				int inputWidth = 6;
				PIXEL(finalColor, draw_input_data(x, y, 0, 0 * 8 + 128, _State_00, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 1 * 8 + 128, _State_01, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 2 * 8 + 128, _State_02, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 3 * 8 + 128, _State_03, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 4 * 8 + 128, _State_04, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 5 * 8 + 128, _State_05, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 6 * 8 + 128, _State_06, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 7 * 8 + 128, _State_07, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 8 * 8 + 128, _State_08, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 9 * 8 + 128, _State_09, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 10 * 8 + 128, _State_10, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 11 * 8 + 128, _State_11, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 12 * 8 + 128, _State_12, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 13 * 8 + 128, _State_13, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 14 * 8 + 128, _State_14, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data(x, y, 0, 15 * 8 + 128, _State_15, _Sprites, _Font));

				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 0 + 128, _State_00, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 1 + 128, _State_01, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 2 + 128, _State_02, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 3 + 128, _State_03, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 4 + 128, _State_04, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 5 + 128, _State_05, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 6 + 128, _State_06, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 7 + 128, _State_07, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 8 + 128, _State_08, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 9 + 128, _State_09, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 10 + 128, _State_10, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 11 + 128, _State_11, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 12 + 128, _State_12, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 13 + 128, _State_13, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 14 + 128, _State_14, _Sprites, _Font));
				PIXEL(finalColor, draw_input_data_mini(254-x, y, 0, 15 + 128, _State_15, _Sprites, _Font));

				int textX = 0;
				int textY = 8;
				PIXEL(finalColor, draw_integer(x, y, textX, textY, _IsMaster, _Font));
				textY = 16;
				PIXEL(finalColor, draw_integer(x, y, textX, textY, _CurrentNetworkFrame, _Font));
				textY = 24;
				PIXEL(finalColor, draw_integer(x, y, textX, textY, currentFrame, _Font));
				textY = 32;
				PIXEL(finalColor, draw_integer(x, y, textX, textY, clockTick, _Font));
				textY = 40;
				PIXEL(finalColor, draw_integer(x, y, textX, textY, upperNetClock, _Font));

				

				PIXEL(finalColor, save_upper_state(x, y));

				return finalColor;
			}
			ENDCG
		}
	}
}
