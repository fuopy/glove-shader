#include "shi_shared.hlsl"
#include "shi_leveldata.hlsl"

// GENERAL ROUTINES /////////////////////////////////////////////////////////
// PHYSICS //

#define WIDTH 8
#define HEIGHT 8

bool intersectSpriteSprite(int x1, int y1, int x2, int y2)
{
	return ((x1 < x2+WIDTH) &&
		(x1+WIDTH > x2) &&
		(y1 < y2+HEIGHT) &&
		(y1+HEIGHT > y2));
}

bool collideSpriteSprite(inout int x1, inout int y1, bool horiz, inout int vel, int x2, int y2)
{
	if( (x1 < x2+WIDTH) &&
		(x1+WIDTH > x2) &&
		(y1 < y2+HEIGHT) &&
		(y1+HEIGHT > y2))
	{
		if(horiz)
		{
			if(vel < 0)
			{
				x1 = x2+WIDTH;
			}
			else
			{
				x1 = x2-WIDTH;
			}
		}
		else
		{
			if(vel < 0)
			{
				y1 = y2+HEIGHT;
			}
			else
			{
				y1 = y2-HEIGHT;
			}
		}
		vel = 0;
		return true;
	}
	return false;
}

bool collideSpriteWall(inout int x1, inout int y1, bool horiz, inout int vel, int x2, int y2, int w2, int h2)
{
	if( (x1 < x2+w2) &&
	(x1+WIDTH > x2) &&
	(y1 < y2+h2) &&
	(y1+HEIGHT > y2))
	{
		if(horiz)
		{
			if(vel < 0)
			{
				x1 = x2+w2;
			}
			else
			{
				x1 = x2-WIDTH;
			}
		}
		else
		{
			if(vel < 0)
			{
				y1 = y2+h2;
			}
			else
			{
				y1 = y2-HEIGHT;
			}
		}
		vel = 0;
		return true;
	}
	return false;
}

// FORWARD DECLARES //
void damage_spawner(inout Spawner obj, int dmg);
void addScore(int points);
void flashScreen();
void damage_explorer(inout Explorer obj, int dmg);
void activate_key(inout Key obj);
void activate_treasure(inout Treasure obj);
void doGameComplete();
void worldClearLevel();
void markRoomAsCleared(int room);
void gameGotoLevel(uint level);
void displayGame();
void gameLevelName();
void doGameOver();

// TYPE ROUTINES ////////////////////////////////////////////////////////////
// BADGUY ///////////////////////////////////////////////////////////////////
void add_badguy(int x, int y)
{
	bool found = false;
	int foundIndex;
	for (foundIndex = 0; foundIndex < numBadguys; ++foundIndex) {
		if (!badguys[foundIndex].active) {
			badguys[foundIndex].active = true;
			badguys[foundIndex].x = x;
			badguys[foundIndex].y = y;
			found = true;
			break;
		}
	}

	if (!found) return;

	bool valid = true;
	for (int j = 0; j < numBadguys; ++j) {
		if (!badguys[j].active || (foundIndex == j)) continue;
		int wx = badguys[j].x;
		int wy = badguys[j].y;
		if ((badguys[foundIndex].x < wx + 8) &&
			(badguys[foundIndex].x + 8 > wx) &&
			(badguys[foundIndex].y < wy + 8) &&
			(badguys[foundIndex].y + 8 > wy))
		{
			valid = false;
			break;
		}
	}

	if (!valid) badguys[foundIndex].active = false;
}

void update_badguy(inout BadGuy obj, int id)
{
	int i;
	int vx, vy;
	int wx, wy, ww, wh;

	// Skip processing if this object is dead
	if (!obj.active) return;

	// Get horizontal velocity
	if (obj.x > p1.x) vx = -1;
	else if (obj.x < p1.x) vx = 1;
	else vx = 0;

	// Set horizontal position
	obj.x += vx;
	obj.x = (obj.x + 8 > gamew) ? gamew - 8 : obj.x;
	obj.x = (obj.x < 0) ? 0 : obj.x;

	// WALL COLLISION
	for (i = 0; i < numWalls; ++i) {
		if (!walls[i].active) continue;
		wx = walls[i].x * 8;
		wy = walls[i].y * 8;
		ww = walls[i].w * 8;
		wh = walls[i].h * 8;
		collideSpriteWall(obj.x, obj.y, true, vx, wx, wy, ww, wh);
	}

	// BADGUY COLLISION
	for (i = 0; i < numBadguys; ++i) {
		if (!badguys[i].active || (id == i)) continue; // TODO: Fix Comparison
		wx = badguys[i].x;
		wy = badguys[i].y;
		collideSpriteSprite(obj.x, obj.y, true, vx, wx, wy);
	}

	// PLAYER COLLISION
	if (collideSpriteSprite(obj.x, obj.y, true, vx, p1.x, p1.y))
	{
		damage_explorer(p1, 1);
	}

	// Get vertical velocity
	if (obj.y > p1.y) vy = -1;
	else if (obj.y < p1.y) vy = 1;
	else vy = 0;

	// Set verical position
	obj.y += vy;
	obj.y = (obj.y + 8 > gameh) ? gameh - 8 : obj.y;
	obj.y = (obj.y < 0) ? 0 : obj.y;

	// WALL COLLISION
	for (i = 0; i < numWalls; ++i) {
		if (!walls[i].active) continue;
		wx = walls[i].x * 8;
		wy = walls[i].y * 8;
		ww = walls[i].w * 8;
		wh = walls[i].h * 8;
		collideSpriteWall(obj.x, obj.y, false, vy, wx, wy, ww, wh);
	}

	// BADGUY COLLISION
	for (i = 0; i < numBadguys; ++i) {
		if (!badguys[i].active || (id == i)) continue;
		wx = badguys[i].x;
		wy = badguys[i].y;
		collideSpriteSprite(obj.x, obj.y, false, vy, wx, wy);
	}

	// PLAYER COLLISION
	if (collideSpriteSprite(obj.x, obj.y, false, vy, p1.x, p1.y))
	{
		damage_explorer(p1, 1);
	}
}
void destroy_badguy(inout BadGuy obj)
{
	if (obj.active) {
		// TODO: Sound Effect.
		obj.active = false;
	}
}
// BULLET ///////////////////////////////////////////////////////////////////
void add_bullet(int x, int y, int vx, int vy)
{
	for (int i = 0; i < numBullets; ++i) {
		if (!bullets[i].active) {
			// TODO: Play sound effect.
			bullets[i].active = true;
			bullets[i].x = x;
			bullets[i].y = y;
			bullets[i].vx = vx;
			bullets[i].vy = vy;
			bullets[i].lifetime = 20;
			return;
		}
	}
}
void update_bullet(inout Bullet obj)
{
	int wx, wy, ww, wh;
	int i;

	// Skip processing if bullet is dead
	if (!obj.active) return;

	// Update horizontal position
	obj.x += obj.vx;

	// Touch game border
	if ((obj.x + 4 < 0) || (obj.x > gamew)) {
		obj.active = false;
		return;
	}

	// Update vertical position
	obj.y += obj.vy;

	// Touch game border
	if ((obj.y + 4 < 0) || (obj.y > gameh)) {
		obj.active = false;
		return;
	}

	// Reduce active time
	obj.lifetime--;
	obj.active = obj.lifetime > 0;

	// BADGUY COLLISION
	for (i = 0; i < numBadguys; ++i) {
		if (badguys[i].active && (
			(obj.x < badguys[i].x + 8) &&
			(obj.x + 1 > badguys[i].x) &&
			(obj.y < badguys[i].y + 8) &&
			(obj.y + 1 > badguys[i].y)))
		{
			obj.active = false;
			destroy_badguy(badguys[i]);
			return;
		}
	}


	// WALL COLLISION
	for (i = 0; i < numWalls; ++i) {
		if (!walls[i].active) continue;
		wx = walls[i].x * 8;
		wy = walls[i].y * 8;
		ww = walls[i].w * 8;
		wh = walls[i].h * 8;
		if ((obj.x < wx + ww) &&
			(obj.x + 1 > wx) &&
			(obj.y < wy + wh) &&
			(obj.y + 1 > wy))
		{
			obj.active = false;
		}
	}

	// SPAWNER COLLISION
	for (i = 0; i < numSpawners; ++i) {
		if (!spawners[i].active) continue;
		wx = spawners[i].x * 8;
		wy = spawners[i].y * 8;
		ww = 8;
		wh = 8;
		if ((obj.x < wx + ww) &&
			(obj.x + 1 > wx) &&
			(obj.y < wy + wh) &&
			(obj.y + 1 > wy))
		{
			damage_spawner(spawners[i], 10);
			obj.active = false;
		}
	}
}
// EXIT /////////////////////////////////////////////////////////////////////
void add_exit(int x, int y, int dest)
{
	for (int i = 0; i < numExits; ++i) {
		if (!exits[i].active) {
			exits[i].active = true;
			exits[i].x = x;
			exits[i].y = y;
			exits[i].dest = dest;
			return;
		}
	}
}
void activate_exit(inout Exit obj)
{
	levelsCompleted++;
	if (!quitGame)
	{
		// If playing RANDOM mode
		if (GameMode == GAME_MODE_RANDOM) {
			//gameGotoLevel(random(0, numLevels - 1));
			// TODO GOTO LEVEL
			// In any other mode
		}
		else {
			// Mark this room as cleared in save file
			markRoomAsCleared(currentLevel);
			gameGotoLevel(obj.dest);
		}
	}
}
// EXPLORER /////////////////////////////////////////////////////////////////
void initialize_explorer(inout Explorer obj)
{
	// Set default values
	obj.x = spawnx * 8;
	obj.y = spawny * 8;
	obj.direction = FACE_UP;
	obj.frame = false;
	obj.frameTime = 0;
	obj.active = true;
	obj.health = 1000;
	obj.nextHealthDecrease = 5;
}
void update_explorer(inout Explorer obj)
{
	int i, vx, vy;
	int wx, wy, ww, wh;
	int nvx, nvy;

	// TODO: Game over if button pressed while dead
	if (!obj.active) {
		if ((B_PRESSED || A_PRESSED) && !quitGame) {
			doGameOver();
		}
		return;
	}

	// Add health from rolling health
	if (rollingHealth > 0) {
		rollingHealth -= 10;
		obj.health += 10;
		if (obj.health > 1000) {
			obj.health = 1000;
			rollingHealth = 0;
		}
	}

	// Decrease health
	if (obj.nextHealthDecrease <= 0) {
		obj.nextHealthDecrease = 5;
		damage_explorer(obj, 1);
	}
	obj.nextHealthDecrease--;

	// Update animation
	if (LEFT_DOWN || RIGHT_DOWN || UP_DOWN || DOWN_DOWN) {
		obj.frameTime++;
		if (obj.frameTime > 8) {
			obj.frame = (obj.frame == 1) ? 0 : 1;
			obj.frameTime = 0;
		}
	} else {
		// If facing left or right, set sprite to standing
		if (obj.direction == FACE_LEFT || obj.direction == FACE_RIGHT)
			obj.frame = true;
	}

	// Get horizontal velocity
	if (RIGHT_DOWN) {
		vx = 1;
		obj.direction = FACE_RIGHT;
	} else if (LEFT_DOWN) {
		vx = -1;
		obj.direction = FACE_LEFT;
	} else {
		vx = 0;
	}

	// Update horizontal position
	obj.x += vx;
	obj.x = (obj.x + 8 > gamew) ? gamew - 8 : obj.x;
	obj.x = (obj.x < 0) ? 0 : obj.x;

	// WALL COLLISION
	for (i = 0; i < numWalls; ++i) {
		if (!walls[i].active) continue;
		wx = walls[i].x * 8;
		wy = walls[i].y * 8;
		ww = walls[i].w * 8;
		wh = walls[i].h * 8;
		collideSpriteWall(obj.x, obj.y, true, vx, wx, wy, ww, wh);
	}
	// SPAWNER COLLISION
	for (i = 0; i < numSpawners; ++i) {
		if (!spawners[i].active) continue;
		wx = spawners[i].x * 8;
		wy = spawners[i].y * 8;
		collideSpriteSprite(obj.x, obj.y, true, vx, wx, wy);
	}

	// BADGUY COLLISION
	for (i = 0; i < numBadguys; ++i) {
		if (!badguys[i].active) continue;
		wx = badguys[i].x;
		wy = badguys[i].y;
		if (collideSpriteSprite(obj.x, obj.y, true, vx, wx, wy))
		{
			damage_explorer(obj, 1);
		}
	}

	// Get vertical velocity
	if (DOWN_DOWN) {
		vy = 1;
		obj.direction = FACE_DOWN;
	}
	else if (UP_DOWN) {
		vy = -1;
		obj.direction = FACE_UP;
	}
	else {
		vy = 0;
	}

	// Update vertical position
	obj.y += vy;
	obj.y = (obj.y + 8 > gameh) ? gameh - 8 : obj.y;
	obj.y = (obj.y < 0) ? 0 : obj.y;

	// WALL COLLISION
	for (i = 0; i < numWalls; ++i) {
		if (!walls[i].active) continue;
		wx = walls[i].x * 8;
		wy = walls[i].y * 8;
		ww = walls[i].w * 8;
		wh = walls[i].h * 8;
		collideSpriteWall(obj.x, obj.y, false, vy, wx, wy, ww, wh);
	}

	// SPAWNER COLLISION
	for (i = 0; i < numSpawners; ++i) {
		if (!spawners[i].active) continue;
		wx = spawners[i].x * 8;
		wy = spawners[i].y * 8;
		collideSpriteSprite(obj.x, obj.y, false, vy, wx, wy);
	}

	// BADGUY COLLISION
	for (i = 0; i < numBadguys; ++i) {
		if (!badguys[i].active) continue;
		wx = badguys[i].x;
		wy = badguys[i].y;
		if (collideSpriteSprite(obj.x, obj.y, false, vy, wx, wy))
		{
			damage_explorer(obj, 1);
		}
	}

	// KEY COLLISION
	for (i = 0; i < numKeys; ++i) {
		if (!keys[i].active) continue;
		wx = keys[i].x * 8;
		wy = keys[i].y * 8;
		if (intersectSpriteSprite(obj.x, obj.y, wx, wy))
		{
			activate_key(keys[i]);
		}
	}

	// EXIT COLLISION
	for (i = 0; i < numExits; ++i) {
		if (!exits[i].active) continue;
		wx = exits[i].x * 8;
		wy = exits[i].y * 8;
		if (intersectSpriteSprite(obj.x, obj.y, wx, wy))
		{
			activate_exit(exits[i]);
		}
	}

	// TREASURE COLLISION
	for (i = 0; i < numTreasures; ++i) {
		if (!treasures[i].active) continue;
		wx = treasures[i].x * 8;
		wy = treasures[i].y * 8;
		if (intersectSpriteSprite(obj.x, obj.y, wx, wy))
		{
			activate_treasure(treasures[i]);
		}
	}

	// Player shooting
	if (A_PRESSED) {
		autoFireTime = 8;
		nvx = (obj.direction == FACE_LEFT || LEFT_DOWN) ? -2 : 0;
		nvx = (obj.direction == FACE_RIGHT || RIGHT_DOWN) ? 2 : nvx;
		nvy = (obj.direction == FACE_UP || UP_DOWN) ? -2 : 0;
		nvy = (obj.direction == FACE_DOWN || DOWN_DOWN) ? 2 : nvy;

		add_bullet(obj.x + 3, obj.y + 3, nvx + vx, nvy + vy);
	}

	// Update Camera
	scrollx = 64 - obj.x;
	scrolly = 32 - obj.y;
}
void damage_explorer(inout Explorer obj, int dmg)
{
	// Remove health
	obj.health -= dmg;

	// Kill player if health drops below zero
	if (obj.health <= 0) {
		obj.active = false;
		obj.health = 0;
	}
}
// KEY //////////////////////////////////////////////////////////////////////
void add_key(int x, int y, uint target)
{
	for (int i = 0; i < numKeys; i++) {
		if (!keys[i].active) {
			keys[i].active = true;
			keys[i].x = x;
			keys[i].y = y;
			keys[i].target = target;
			return;
		}
	}
}
void activate_key(inout Key obj)
{
	if (obj.active)
	{
		walls[obj.target].active = false;
		obj.active = false;
		// TODO: SFX
	}
}
// SPAWNER //////////////////////////////////////////////////////////////////
void add_spawner(int x, int y)
{
	for (int i = 0; i < numSpawners; i++) {
		if (!spawners[i].active) {
			spawners[i].active = true;
			spawners[i].x = x;
			spawners[i].y = y;
			spawners[i].spawnDelay = 100;
			spawners[i].health = 50;
			return;
		}
	}
}
void update_spawner(inout Spawner obj)
{
	if (!obj.active) return;
	if (obj.spawnDelay <= 0) {
		add_badguy(obj.x * 8 + 4, obj.y * 8 + 4);
		obj.spawnDelay = 100;
	}
	obj.spawnDelay--;
}
void destroy_spawner(inout Spawner obj)
{
	obj.active = false;
}
void damage_spawner(inout Spawner obj, int dmg)
{
	obj.health -= dmg;
	if (obj.health <= 0)
	{
		obj.active = false;
		addScore(1);
		// TODO: SFX
	}
	else {
		; // TODO: SFX
	}
}
// TREASURE /////////////////////////////////////////////////////////////////
void add_treasure(int x, int y, int type)
{
	for (int i = 0; i < numTreasures; i++) {
		if (!treasures[i].active) {
			treasures[i].active = true;
			treasures[i].x = x;
			treasures[i].y = y;
			treasures[i].type = type;
			return;
		}
	}
}
void activate_treasure(inout Treasure obj)
{
	int i;
	obj.active = false;
	switch (obj.type) {
	case TREASURE_GOLD: // Awards 10 points
		addScore(10);
		// TODO: SFX
		break;
	case TREASURE_POO: // Kills all baddies on screen
		for (i = 0; i < numBadguys; ++i) {
			badguys[i].active = false;
		}
		flashScreen();
		// TODO: SFX
		break;
	case TREASURE_CUP: // Awards 6 points
		addScore(6);
		// TODO: SFX
		break;
	case TREASURE_LEMON: // Awards 300 health
		rollingHealth += 300;
		// TODO: SFX
		break;
	}
	obj.active = false;
}
// WALL /////////////////////////////////////////////////////////////////////
void add_wall(int x, int y, int w, int h, int style)
{
	for (int i = 0; i < numWalls; ++i)
	{
		if (!walls[i].active)
		{
			walls[i].active = true;
			walls[i].x = x;
			walls[i].y = y;
			walls[i].w = w;
			walls[i].h = h;
			walls[i].style = style;
			return;
		}
	}
}
// world ////////////////////////////////////////////////////////////////////
void worldLoadLevel()
{
	// TODO. Load Level.

	uint level = currentLevel;
	int i;
	uint x, y, w, h, dest, target;
	uint dataItem;
	int style;
	bool direction;
	int levelOffset = level * 32;
	
	// Clear the level
	worldClearLevel();
	
	// Read shorts from the memory
	for(int i=0; i<32; ++i) {
		dataItem = levelData[levelOffset + i];
		
		if(i < 16) { // Read a wall
			x = (dataItem >> 11) & 31;
			y = (dataItem >> 7) & 15;
			dest = (dataItem >> 2) & 31;
			style = (dataItem >> 1) & 1;
			direction = (dataItem) & 1;
			w = direction ? 1 : dest+1;
			h = direction ? dest+1 : 1;
			add_wall(x, y, w, h, style);
		} else if(i >= 16 && i < 20) { // Read a spawner
			x = (dataItem >> 11) & 31;
			y = (dataItem >> 7) & 15;
			add_spawner(x, y);
		} else if(i >= 20 && i < 24) { // Read a key
			x = (dataItem >> 11) & 31;
			y = (dataItem >> 7) & 15;
			target = (dataItem >> 3) & 15;
			add_key(x, y, target);
		} else if(i >= 24 && i < 25) { // Read a start
			spawnx = (dataItem >> 11) & 31;
			spawny = (dataItem >> 7) & 15;
		} else if(i >= 25 && i < 29) { // Read an exit
			x = (dataItem >> 11) & 31;
			y = (dataItem >> 7) & 15;
			dest = (dataItem) & 127;
			add_exit(x, y, dest);
		} else if(i >= 29 && i < 32) { // Read a treasure
			x = (dataItem >> 11) & 31;
			y = (dataItem >> 7) & 15;
			target = (dataItem >> 4) & 7; // type
			dest = (dataItem) & 15; // layout
			
			if(target == 0) continue; // If the type is zero, don't do squat with it
			
			switch(dest) { case 0: case 1: case 2: case 3: case 5: case 6: case 9: case 10: case 11: case 12: case 14:
					add_treasure(x, y, target);
			break; }
			switch(dest) { case 2: case 4: case 7: case 9: case 13: case 15:
					add_treasure(x+1, y, target);
			break; }
			switch(dest) { case 8: case 14:
					add_treasure(x+2, y, target);
			break; }
			
			switch(dest) { case 1: case 4: case 8: case 11: case 15:
					add_treasure(x, y+1, target);
			break; }
			switch(dest) { case 3: case 10:
					add_treasure(x+1, y+1, target);
			break; }
			switch(dest) { case 5: case 9:
					add_treasure(x+2, y+1, target);
			break; }
			
			switch(dest) { case 7: case 12: case 13:
					add_treasure(x, y+2, target);
			break; }
			switch(dest) { case 6: case 11: case 14: case 15:
					add_treasure(x+1, y+2, target);
			break; }
			switch(dest) { case 10: case 12: case 13:
					add_treasure(x+2, y+2, target);
			break; }
		}
	}
	p1.x = spawnx*8;
	p1.y = spawny*8;
}

void worldClearLevel()
{
	int i;
	for (i = 0; i < numBadguys; ++i) {
		badguys[i].active = false;
	}
	for (i = 0; i < numSpawners; ++i) {
		spawners[i].active = false;
	}
	for (i = 0; i < numKeys; ++i) {
		keys[i].active = false;
	}
	for (i = 0; i < numExits; ++i) {
		exits[i].active = false;
	}
	for (i = 0; i < numWalls; ++i) {
		walls[i].active = false;
	}
	for (i = 0; i < numBullets; ++i) {
		bullets[i].active = false;
	}
	for (i = 0; i < numTreasures; ++i) {
		treasures[i].active = false;
	}
}

// game /////////////////////////////////////////////////////////////////////
void gameGotoLevel(uint level)
{	
	// If the level destination is zero, increment the current level
	if (level == 0) level = 1;

	// Wrap the last level around to the first
	if (level == 255) level = 0;

	// If there are no more levels, finish the game
	if (level >= numLevels) {
		doGameComplete();
		return;
	}

	// Add the remainder of rolling score to score variable
	if (rollingScore > 0) score += rollingScore;

	// Hide the rolling score
	rollingScore = -30;

	// Add the remainder of rolling health to health variable
	if (rollingHealth > 0) p1.health += rollingHealth;
	rollingHealth = 0;

	// Set the current level
	currentLevel = level;

	// Autosave progress
	//saveGame(GAME_SAVE_FILE); // TODO: Alternative to saving.

	// Draw the level name
	// TODO: Draw Level Name in bottom left corner. For One Second.
	//gameState = GAMESTATE_GAME_LEVELNAME;
	gameLevelName();
}

void gameSetup()
{
	// Initialize game variables
	levelsCompleted = 0;
	autoFireTime = 0;
	rollingScore = -30;
	quitGame = false;
	initialize_explorer(p1);
	currentLevel = 0;
}

void titleUpdate()
{
	if (A_PRESSED)
	{
		displayGame();
	}
}

void levelNameUpdate()
{
	wallsMap--;

	if (wallsMap == 1)
	{
		// Load the next level
		worldLoadLevel();
	}
	
	if (wallsMap <= 0)
	{
		gameState = GAMESTATE_GAME_LOOP;
	}
}

void gameEndUpdate()
{
	if (A_PRESSED)
	{
		gameState = GAMESTATE_GAME_TITLE;
	}
}

void hiscoreInputUpdate()
{
	// TODO: Allow input.
	if (A_PRESSED)
	{
		gameState = GAMESTATE_MAIN_MENU;
	}
}

void mainMenuUpdate()
{
	// TODO: Allow input.
	if (A_PRESSED)
	{
		displayGame();
	}
}

void hiscoreViewUpdate()
{
	// TODO: Allow input.
	if (A_PRESSED)
	{
		gameState = GAMESTATE_MAIN_MENU;
	}
}

void gameUpdate()
{
	int i;

	// Update the spawners
	for (i = 0; i < numSpawners; ++i) update_spawner(spawners[i]);

	// Update the bad guys, if it's time
	if (BadGuy_UpdateDelay <= 0)
	{
		// Update the badguys
		for (i = 0; i < numBadguys; ++i) update_badguy(badguys[i], i);

		// Set delay until next update
		BadGuy_UpdateDelay = 3;
	}

	// Update timer
	BadGuy_UpdateDelay--;

	//// Update the bullets
	for (i = 0; i < numBullets; ++i) update_bullet(bullets[i]);

	// Update the player
	update_explorer(p1);

	// Add score from the rolling score
	if (rollingScore > 0) score++;

	// Update timer that persists after rolling score is empty
	if (rollingScore > -30) rollingScore--;

	//// Update the game timer
	if (gameTimeTick <= 0) {
		gameTime++;
		gameTimeTick = 46;
	}
	gameTimeTick--;
}
void flashScreen()
{
	// TODO
	//whiteScreenTime = 2;
}
void addScore(int points)
{
	// If at end of score rolling animation, set the score
	if (rollingScore < 0)
	{
		rollingScore = points;
	}
	// Add to the rolling score
	else
	{
		rollingScore += points;
	}
}

void displayGameEnd()
{
	// Draw Game End

	// Wait for input

    // Quit game, delete save and handle high score input
	quitGame = true;
	// deleteContinueSave();
	// saveHighScore();
}

void doGameComplete()
{
	gameState = GAMESTATE_GAME_COMPLETE;
}

void doGameOver()
{
	gameState = GAMESTATE_GAME_OVER;
}

void gameLevelName()
{
	wallsMap = 30;
	gameState = GAMESTATE_GAME_LEVELNAME;
}

void gameLoop()
{
	gameState = GAMESTATE_GAME_LOOP;
}

void displayGame()
{
	// Setup game
	gameSetup();

	// Clear variables
	score = 0;
	gameTime = 0;
	gameTimeTick = 0;

	// Go to first level
	//if (GameMode == GAME_MODE_RANDOM) TODO: WHAT IS RANDOM LOL
//		gameGotoLevel(random(0, numLevels - 1));
	//else
		gameGotoLevel(255);

	// Enter game loop
	//gameLoop();
	//gameLevelName();
}


void markRoomAsCleared(int room)
{
	//TODO: Make sure there's actually stuff getting saved.
	
	//if(room > numLevels) return;
	//int address = GameSaveOffset;
	//int pos = address+FILE_COMPLETION+(room/8);
	//char data = EEPROM.read(pos);
	//data |= 1 << (room%8);
	//EEPROM.write(pos, data);
}

