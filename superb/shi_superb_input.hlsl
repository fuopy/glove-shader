#define PIXEL(var, color) var = (color); if (var[1] > 0.5) return var;

static const float4 okayFloat4 = { 0, 0, 0, 0 };

bool hitbox(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2)
{
	return (x1 + w1 >= x2) && (x1 < x2 + w2) && (y1 + h1 >= y2) && (y1 < y2 + h2);
}

float4 draw_pixel(int x, int y, int px, int py)
{
	if (x == px && y == py)
	{
		return float4(1, 1, 1, 1);
	}
	return okayFloat4;
}

float4 draw_sprite(int x, int y, int sx, int sy, uint id, texture2D tex)
{
	if (hitbox(x, y, 0, 0, sx, sy, 8, 8))
	{
		//if (true)
			//return float4( 1, 1, 1, 1 );
		int dx = x - sx;
		int dy = y - sy;
		int spx = 8 * (id % 32); // VALID
		int spy = 8 * (id / 32); // VALID
		int2 spritesheetPixel = int2(dx + spx, dy + spy);
		return tex[spritesheetPixel];
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
	int index = 0;
	int gotChar = 0;

	float4 finalColor;

	gotChar = str[index];
	while (index < MAX_STRING_SIZE && gotChar != '\0')
	{
		finalColor = draw_character(x, y, sx, sy, gotChar, tex);
		if (finalColor[0] > .5) return finalColor;
		++index;
		sx += 6;
		gotChar = str[index];
	}
	return okayFloat4;
}
float4 draw_integer(int x, int y, inout int destx, inout int desty, int val, texture2D tex)
{
	// Convert the integer to a base-10 string.
	float4 finalColor;
	int i = val;
	int remainder;
	int finalNumberIter;
	int iterCount;

	int digits[10] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

	if (val < 0)
	{
		i = -i;
		// Too lazy to do negs for now.
		//return okayFloat4;
		finalColor = draw_character(x, y, destx, desty, '-', tex);
		if (finalColor[0] > .5) return finalColor;
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
		finalColor = draw_character(x, y, destx, desty, digits[iterCount - finalNumberIter] + '0', tex);
		if (finalColor[0] > .5) return finalColor;
		destx += 6;
	}
	return okayFloat4;
}