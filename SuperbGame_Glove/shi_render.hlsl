#include "shi_shared.hlsl"

// DATA

#define FONT_WIDTH 6
#define FONT_HEIGHT 8

static const int levelNames[30][16] = {
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 1       \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '2', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 2       \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 3       \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '3', '-', 'B', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 3-B     \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 4       \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 5       \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '5', '-', 'B', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 5-B     \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '5', '-', 'C', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 5-C     \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 6       \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '7', '-', 'A', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 7-A     \0"
	{'B', 'u', 'n', 'k', 'e', 'r', ' ', '7', '-', 'B', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Bunker 7-B     \0"
	{'F', 'o', 'r', 'e', 's', 't', ' ', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Forest 1       \0"
	{'F', 'o', 'r', 'e', 's', 't', ' ', '2', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Forest 2       \0"
	{'F', 'o', 'r', 'e', 's', 't', ' ', '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Forest 3       \0"
	{'C', 'o', 'u', 'r', 't', 'y', 'a', 'r', 'd', ' ', '1', ' ', ' ', ' ', ' ', '\0'}, // "Courtyard 1    \0"
	{'C', 'o', 'u', 'r', 't', 'y', 'a', 'r', 'd', ' ', '2', ' ', ' ', ' ', ' ', '\0'}, // "Courtyard 2    \0"
	{'F', 'o', 'r', 'e', 's', 't', ' ', '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Forest 4       \0"
	{'T', 'r', 'e', 'a', 's', 'u', 'r', 'y', ' ', '1', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Treasury 1     \0"
	{'H', 'e', 'd', 'g', 'e', ' ', 'M', 'a', 'z', 'e', ' ', '1', '-', 'B', ' ', '\0'}, // "Hedge Maze 1-B \0"
	{'H', 'e', 'd', 'g', 'e', ' ', 'M', 'a', 'z', 'e', ' ', '1', ' ', ' ', ' ', '\0'}, // "Hedge Maze 1   \0"
	{'H', 'e', 'd', 'g', 'e', ' ', 'M', 'a', 'z', 'e', ' ', '2', ' ', ' ', ' ', '\0'}, // "Hedge Maze 2   \0"
	{'P', 'l', 'a', 'n', 't', ' ', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Plant 1        \0"
	{'C', 'o', 'u', 'r', 't', 'y', 'a', 'r', 'd', ' ', '3', ' ', ' ', ' ', ' ', '\0'}, // "Courtyard 3    \0"
	{'C', 'o', 'u', 'r', 't', 'y', 'a', 'r', 'd', ' ', '4', ' ', ' ', ' ', ' ', '\0'}, // "Courtyard 4    \0"
	{'C', 'o', 'u', 'r', 't', 'y', 'a', 'r', 'd', ' ', '5', ' ', ' ', ' ', ' ', '\0'}, // "Courtyard 5    \0"
	{'C', 'o', 'u', 'r', 't', 'y', 'a', 'r', 'd', ' ', '5', '-', 'B', ' ', ' ', '\0'}, // "Courtyard 5-B  \0"
	{'T', 'r', 'e', 'a', 's', 'u', 'r', 'y', ' ', '2', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Treasury 2     \0"
	{'T', 'o', 'w', 'e', 'r', ' ', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Tower 1        \0"
	{'T', 'o', 'w', 'e', 'r', ' ', '2', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Tower 2        \0"
	{'B', 'a', 's', 'e', ' ', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}  // "Base 1         \0"
};

static const int miscStrings[26][16] = {
	{'0', '0', ' ', 'p', 't', 's','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "00 pts"
	{'Y', 'o', 'u', ' ', 'c', 'l', 'e', 'a', 'r', 'e', 'd','\0', ' ', ' ', ' ', '\0'}, // "You cleared "
	{' ', 'r', 'o', 'o', 'm', 's','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " rooms"
	{'I', 'n', ' ','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "In "
	{'W', 'i', 't', 'h', ' ', 'a', ' ', 's', 'c', 'o', 'r', 'e', ' ', 'o', 'f', '\0'}, // "With a score of"
	{'0', '0', ' ', 'p', 'o', 'i', 'n', 't', 's','\0', ' ', ' ', ' ', ' ', ' ', '\0'}, // "00 points"
	{'G', 'a', 'm', 'e', ' ', 'C', 'o', 'm', 'p', 'l', 'e', 't', 'e', '!','\0', '\0'}, // "Game Complete!"
	{'G', 'a', 'm', 'e', ' ', 'O', 'v', 'e', 'r','\0', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Game Over"
	{' ', 'R', 'm', 's','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " Rms"
	{' ', 'O', 'n','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " On"
	{' ', 'O', 'f', 'f','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " Off"
	{' ', 'G', 'l', 'o', 'v', 'e','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " Glove"
	{' ', 'R', 'a', 'n', 'd', 'o', 'm','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " Random"
	{' ', '?', '?', '?', '?', '?', '?','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // " ??????"
	{'-', ' ', 'R', 'e', 'c', 'o', 'r', 'd', 's', ' ', '-','\n','\n','\0', ' ', '\0'}, // "- Records -\n\n"
	{'N', 'a', 'm', 'e', ' ', 'S', 'c', 'o', 'r', 'e', ' ', 'T', 'i', 'm', 'e', '\0'}, // "Name Score Time"
	{' ', ' ', '#', 'R', 'm', 's','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "  #Rms"
	{'0', '0','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "00"
	{'R', 'O', 'O', 'M', 'S', ' ', 'C', 'L', 'E', 'A', 'R', 'E', 'D', ':','\0', '\0'}, // "ROOMS CLEARED: "
	{' ', ' ', ' ', 'Y', 'O', 'U', ' ', 'A', 'R', 'E', ' ', 'G', 'R', 'E', 'A', '\0'}, // "   YOU ARE GREA"
	{'T', '!', '!','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "T!!"
	{'Y', 'o', 'u', ' ', 's', 'e', 't', ' ', 'a', ' ', 'h', 'i', 'g', 'h','\0', '\0'}, // "You set a high "
	{'s', 'c', 'o', 'r', 'e', '!','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "score!"
	{'E', 'n', 't', 'e', 'r', ' ', 'n', 'a', 'm', 'e', ':', ' ','\"','\0', ' ', '\0'}, // "Enter name: \""
	{'R', 'O', 'O', 'M', 'S', ' ', 'C', 'L', 'E', 'A', 'R', 'E', 'D', ':','\0', '\0'}, // "ROOMS CLEARED: "
	{'(', 'C', ')', ' ', '2', '0', '1', '6', ' ', 'f', 'u', 'o', 'p', 'y','\0', '\0'}  // "(c) 2016 fuopy"
};

static const int menuStrings[15][22] = {
	{'[', ' ', ' ', ' ', ' ', ' ', 'M', 'a', 'i', 'n', ' ', 'M', 'e', 'n', 'u', ' ', ' ', ' ', ' ', ' ', ']', '\0'}, // "[     Main Menu     ]"
	{'C', 'o', 'n', 't', 'i', 'n', 'u', 'e', ':','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Continue:"
	{'N', 'e', 'w', ' ', 'G', 'a', 'm', 'e','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "New Game"
	{'R', 'e', 'c', 'o', 'r', 'd', 's','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Records"
	{'O', 'p', 't', 'i', 'o', 'n', 's','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Options"
	{'[', ' ', ' ', ' ', 'O', 'p', 't', 'i', 'o', 'n', 's', ' ', 'M', 'e', 'n', 'u', ' ', ' ', ' ', ' ', ']', '\0'}, // "[   Options Menu    ]"
	{'S', 'o', 'u', 'n', 'd', ':','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Sound:"
	{'P', 'l', 'a', 'y','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Play"
	{'R', 'e', 's', 'e', 't', ' ', 'G', 'a', 'm', 'e', ' ', 'D', 'a', 't', 'a','\0', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Reset Game Data"
	{'[', 'R', 'E', 'A', 'L', 'L', 'Y', ' ', 'C', 'L', 'E', 'A', 'R', ' ', 'S', 'A', 'V', 'E', '?', '?', ']', '\0'}, // "[REALLY CLEAR SAVE??]"
	{'N', 'o', ',', ' ', 'w', 'h', 'o', 'o', 'p', 's', '!','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "No, whoops!"
	{'Y', 'e', 's', ',', ' ', 'I','\'', 'm', ' ', 's', 'u', 'r', 'e', '.','\0', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Yes, I'm sure."
	{'Y', 'o', 'u', ' ', 's', 'e', 't', ' ', 'a', ' ', 'h', 'i', 'g', 'h', ' ', 's', 'c', 'o', 'r', 'e', '!', '\0'}, // "You set a high score!"
	{'E', 'n', 't', 'e', 'r', ' ', 'n', 'a', 'm', 'e', ':', ' ','\"','\0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}, // "Enter name: \""
	{'\"','\0',' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'}  // "\""
};

// HELPER ROUTINES //////////////////////////////////////////////////////////
float4 draw_background(int x, int y, texture2D tex)
{
	return tex[int2(x, y)];
}
float4 draw_filledrect(int x, int y, int minX, int minY, int maxX, int maxY, float4 color)
{
	if (hitbox(x, y, 0, 0, minX, minY, maxX, maxY))
	{
		return color;
	}
	return okayFloat4;
}
float4 draw_character(int x, int y, int sx, int sy, int id, texture2D tex)
{
	if (hitbox(x, y, 0, 0, sx, sy, 5, 8))
	{
		int dx = x - sx;
		int dy = y - sy;
		int spx = 5 * (id % 16);
		int spy = 8 * (id / 16);
		int2 spritesheetPixel = int2(dx + spx, dy + spy);
		return tex[spritesheetPixel];
	}
	return okayFloat4;
}

#define MAX_STRING_SIZE 30
float4 draw_string(int x, int y, inout int sx, inout int sy, const int str[16], texture2D tex)
{
	float4 finalColor = okayFloat4;
	int index = 0;
	int gotChar = 0;

	gotChar = str[index];
	while (index < MAX_STRING_SIZE && gotChar != '\0')
	{
		PIXEL(finalColor, draw_character(x, y, sx, sy, gotChar, tex));
		++index;
		sx += 6;
		gotChar = str[index];
	}
	return finalColor;
}
float4 draw_integer(int x, int y, inout int destx, inout int desty, int val, texture2D tex)
{
	float4 finalColor = okayFloat4;

	// Convert the integer to a base-10 string.
	int i = val;
	int remainder;
	int finalNumberIter;
	int iterCount;

	int digits[10] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

	if (val < 0)
	{
		i = -i;
		PIXEL(finalColor, draw_character(x, y, destx, desty, '-', tex))
		destx += 6;
	}
	for (iterCount = 0; iterCount < 10; ++iterCount)
	{
		remainder = i % 10;
		i = i / 10;
		digits[iterCount] = remainder;
		if (i == 0) break;
	}
	for (finalNumberIter = 0; finalNumberIter <= iterCount; ++finalNumberIter)
	{
		PIXEL(finalColor, draw_character(x, y, destx, desty, digits[iterCount - finalNumberIter] + '0', tex));
		destx += 6;
	}
	return finalColor;
}

float4 draw_sprite(int x, int y, int sx, int sy, uint id, texture2D tex)
{
	if (hitbox(x, y, 0, 0, sx, sy, 8, 8))
	{
		int dx = x - sx;
		int dy = y - sy;
		int spx = 8 * (id % 16);
		int spy = 8 * (id / 16);
		int2 spritesheetPixel = int2(dx + spx, dy + spy);
		return tex[spritesheetPixel];
	}
	return okayFloat4;
}
float4 draw_sprite_rect(int x, int y, int sx, int sy, int sw, int sh, uint id, texture2D tex)
{
	if (hitbox(x, y, 0, 0, sx, sy, sw*8, sh*8))
	{
		int dx = (uint)(x - sx) % 8;
		int dy = (uint)(y - sy) % 8;
		int spx = 8 * (id % 16);
		int spy = 8 * (id / 16);
		int2 spritesheetPixel = int2(dx + spx, dy + spy);
		return tex[spritesheetPixel];
	}
	return okayFloat4;
}

float4 draw_time(int x, int y, inout int destx, inout int desty, int time, texture2D tex)
{
	float4 finalColor = okayFloat4;

	int mins = time / 60;
	int secs = time % 60;

	if (mins < 10)
	{
		PIXEL(finalColor, draw_character(x, y, destx, desty, '0', tex));
		destx += FONT_WIDTH;
	}
	
	PIXEL(finalColor, draw_integer(x, y, destx, desty, mins, tex));

	PIXEL(finalColor, draw_character(x, y, destx, desty, ':', tex));
	destx += FONT_WIDTH;

	if (secs < 10)
	{
		PIXEL(finalColor, draw_character(x, y, destx, desty, '0', tex));
		destx += FONT_WIDTH;
	}

	PIXEL(finalColor, draw_integer(x, y, destx, desty, secs, tex));

	return finalColor;
}

// TYPE ROUTINES ////////////////////////////////////////////////////////////
// BADGUY ///////////////////////////////////////////////////////////////////
float4 draw_badguy(int x, int y, inout BadGuy obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		int drawSpr = 4;
		//return draw_sprite(x, y, obj.x, obj.y, drawSpr, tex);
		// NEW: Scroll
		PIXEL(finalColor, draw_sprite(x, y, (int)obj.x + (int)scrollx, obj.y + scrolly, drawSpr, tex));
	}
	return finalColor;
}
// BULLET ///////////////////////////////////////////////////////////////////
float4 draw_bullet(int x, int y, inout Bullet obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		int drawSpr = 14;
		PIXEL(finalColor, draw_sprite(x, y, obj.x + scrollx, obj.y + scrolly, drawSpr, tex));
	}
	return finalColor;
}
// EXIT /////////////////////////////////////////////////////////////////////
float4 draw_exit(int x, int y, inout Exit obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		int drawSpr = 13;
		PIXEL(finalColor, draw_sprite(x, y, obj.x * 8 + scrollx, obj.y * 8 + scrolly, drawSpr, tex));
	}
	return finalColor;
}
// EXPLORER /////////////////////////////////////////////////////////////////
float4 draw_explorer(int x, int y, inout Explorer obj, texture2D tex, texture2D font)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		// Draw player sprite.
		int drawSpr = (obj.direction * 2) + (obj.frame % 2) + 64;
		PIXEL(finalColor, draw_sprite(x, y, obj.x + scrollx, obj.y + scrolly, drawSpr, tex));

		// Draw player health.
		if (rollingScore <= -30) {
			int drawx = 0;
			int drawy = scrh-8;
			PIXEL(finalColor, draw_integer(x, y, drawx, drawy, obj.health, font));
		}
	}
	return finalColor;
}
// KEY //////////////////////////////////////////////////////////////////////
float4 draw_key(int x, int y, inout Key obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		int drawSpr = 5;
		PIXEL(finalColor, draw_sprite(x, y, obj.x * 8 + scrollx, obj.y * 8 + scrolly, drawSpr, tex));
	}
	return finalColor;
}
// SPAWNER //////////////////////////////////////////////////////////////////
float4 draw_spawner(int x, int y, inout Spawner obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		int drawSpr = 10;
		PIXEL(finalColor, draw_sprite(x, y, obj.x*8 + scrollx, obj.y*8 + scrolly, drawSpr, tex));
	}
	return finalColor;
}
// TREASURE /////////////////////////////////////////////////////////////////
float4 draw_treasure(int x, int y, inout Treasure obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		// None: 0
		// Gold: 1
		// Poo: 2
		// Cup: 3
		// Lemon: 4
		int drawSpr = 5;
		PIXEL(finalColor, draw_sprite(x, y, obj.x * 8 + scrollx, obj.y * 8 + scrolly, drawSpr + obj.type, tex));
	}
	return finalColor;
}
// WALL /////////////////////////////////////////////////////////////////////
float4 draw_wall(int x, int y, inout Wall obj, texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (obj.active)
	{
		int drawSpr = 11;
		PIXEL(finalColor, draw_sprite_rect(x, y, obj.x * 8 + scrollx, obj.y * 8 + scrolly, obj.w, obj.h, drawSpr + obj.style, tex));
	}
	return finalColor;
}

// GAMESTATE ROUTINES ///////////////////////////////////////////////////////
void displayTitle();

float4 titleDraw(int x, int y, texture2D sprites, texture2D font, texture2D titleImage)
{
	float4 finalColor = okayFloat4;
	PIXEL(finalColor, draw_background(x, y, titleImage));

	// " Glove"
	//int stringX = 32;
	//int stringY = 32;
	//PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[11], font));

	// "(c) 2016"
	int stringX = 16;
	int stringY = scrh-8;
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[25], font));

	return finalColor;
	//PIXEL(draw_integer(x, y, 0, 0, exits[0].active ? 1 : 2, font));
}

float4 levelNameDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	int stringX = 0;
	int stringY = scrh-8;

	// "Dynamic Level Name"
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, levelNames[currentLevel], font));

	return finalColor;
}

float4 gameDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	
	int iter;
	int drawSpr = 11;

	// Draw flash effect
	if (whiteScreenTime > 0) {
		whiteScreenTime--;
		return float4(1, 1, 1, 0);
	}

	// Draw the player
	PIXEL(finalColor, draw_explorer(x, y, p1, sprites, font));

	// Draw score
	if (rollingScore > -30) {
		int xPos = 0;
		int yPos = scrh - 8;
		PIXEL(finalColor, draw_integer(x, y, xPos, yPos, score, font));
		PIXEL(finalColor, draw_string(x, y, xPos, yPos, miscStrings[0], font));
		PIXEL(finalColor, draw_filledrect(x, y, 0, yPos, xPos, yPos + 8, blackColor))
	}

	// Draw all walls
	for (iter = 0; iter < numWalls; ++iter)
	{
		PIXEL(finalColor, draw_wall(x, y, walls[iter], sprites));
	}

	// Draw level border
	PIXEL(finalColor, draw_sprite_rect(x, y, scrollx - 8, scrolly - 8, MAP_WIDTH + 2, 1, drawSpr, sprites));
	PIXEL(finalColor, draw_sprite_rect(x, y, scrollx - 8, gameh + scrolly, MAP_WIDTH + 2, 1, drawSpr, sprites));
	
	PIXEL(finalColor, draw_sprite_rect(x, y, scrollx - 8, scrolly, 1, MAP_HEIGHT, drawSpr, sprites));
	PIXEL(finalColor, draw_sprite_rect(x, y, gamew + scrollx, scrolly, 1, MAP_HEIGHT, drawSpr, sprites));

	// Draw game objects
	// Draw Spawners.
	for (iter = 0; iter < numSpawners; ++iter)
	{
		PIXEL(finalColor, draw_spawner(x, y, spawners[iter], sprites));
	}
	// Draw Treasure.
	for (iter = 0; iter < numTreasures; ++iter)
	{
		PIXEL(finalColor, draw_treasure(x, y, treasures[iter], sprites));
	}

	// Draw Keys.
	for (iter = 0; iter < numKeys; ++iter)
	{
		PIXEL(finalColor, draw_key(x, y, keys[iter], sprites));
	}

	// Draw Exits.
	for (iter = 0; iter < numExits; ++iter)
	{
		PIXEL(finalColor, draw_exit(x, y, exits[iter], sprites));
	}

	// Draw BadGuys.
	for (iter = 0; iter < numBadguys; ++iter)
	{
		PIXEL(finalColor, draw_badguy(x, y, badguys[iter], sprites));
	}

	// Draw Bullets.
	for (iter = 0; iter < numBullets; ++iter)
	{
		PIXEL(finalColor, draw_bullet(x, y, bullets[iter], sprites));
	}
	return finalColor;
}

float4 gameOverDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;

	int stringX = 5 * 8 - 4;
	int stringY = 8 * 1;

	// "Game Over"
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[7], font));
	return finalColor;
}
float4 gameCompleteDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	int stringX = 3 * 6;
	int stringY = 8 * 1;

	// ""Game Complete!"
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[6], font));
	return finalColor;
}
float4 gameEndDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	int stringX = 6;
	int stringY = 8 * 3;

	// "You cleared "
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[1], font));

	// "Dynamic Number: Room Count"
	stringX += 6;
	PIXEL(finalColor, draw_integer(x, y, stringX, stringY, levelsCompleted, font));

	// " rooms"
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[2], font));

	stringX = 6 * 6;
	stringY = 8 * 4;
	// "In "
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[3], font));

	// "XX:XX"
	PIXEL(finalColor, draw_time(x, y, stringX, stringY, gameTime, font));

	stringX = 2 * 8;
	stringY = 8 * 5;
	// "With a score of"
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[4], font));

	// Dynamic number: points.
	stringX = 6 * 5;
	stringY = 8 * 6;
	PIXEL(finalColor, draw_integer(x, y, stringX, stringY, score, font));

	// "00 points"
	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[5], font));

	return finalColor;
}
float4 hiscoreInputDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	int stringX = 0;
	int stringY = 0;

	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[1], font));
	return finalColor;
}
float4 mainMenuDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	int stringX = 0;
	int stringY = 0;

	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[1], font));
	return finalColor;
}
float4 hiscoreViewDraw(int x, int y, texture2D sprites, texture2D font)
{
	float4 finalColor = okayFloat4;
	int stringX = 0;
	int stringY = 0;

	PIXEL(finalColor, draw_string(x, y, stringX, stringY, miscStrings[1], font));
	return finalColor;
}
