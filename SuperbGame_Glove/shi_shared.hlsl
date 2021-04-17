#ifndef _SUPERB_SHARED_HLSL_
#define _SUPERB_SHARED_HLSL_

// DEFINES //////////////////////////////////////////////////////////////////
#define DATA_TEX_WIDTH 256
#define DATA_TEX_HEIGHT 256

#define FACE_UP 0
#define FACE_DOWN 1
#define FACE_LEFT 2
#define FACE_RIGHT 3

#define TREASURE_NONE 0
#define TREASURE_GOLD 1
#define TREASURE_POO 2
#define TREASURE_CUP 3
#define TREASURE_LEMON 4

#define MAP_WIDTH 32
#define MAP_HEIGHT 16

#define FILE_VALID 0
#define FILE_COMPLETION 5

#define FILE_SCORE 0
#define FILE_TIME 2
#define FILE_LEVEL 4
#define FILE_CURRENT_LEVEL 5
#define FILE_HEALTH 6
#define FILE_NAME 6
#define FILE_CONTINUE 9

#define A_DOWN new_a
#define A_PRESSED (new_a && !old_a)
#define A_RELEASED (!new_a && old_a)

#define B_DOWN new_b
#define B_PRESSED (new_b && !old_b)
#define B_RELEASED (!new_b && old_b)

#define UP_DOWN new_up
#define UP_PRESSED (new_up && !old_up)
#define UP_RELEASED (!new_up && old_up)

#define DOWN_DOWN new_down
#define DOWN_PRESSED (new_down && !old_down)
#define DOWN_RELEASED (!new_down && old_down)

#define LEFT_DOWN new_left
#define LEFT_PRESSED (new_left && !old_left)
#define LEFT_RELEASED (!new_left && old_left)

#define RIGHT_DOWN new_right
#define RIGHT_PRESSED (new_right && !old_right)
#define RIGHT_RELEASED (!new_right && old_right)

#define GAME_NOTHING 0
#define GAME_REBOOT 1

#define GAME_SAVE_FILE 6 // Save file for use with the game
#define GAME_RANDOM_FILE 7 // Save file for use with random
#define GAME_GLOVE_OFFSET (GAME_SAVE_FILE * 10 * 5)
#define GAME_RANDOM_OFFSET (GAME_RANDOM_FILE * 10 * 5)

#define GAME_MODE_GLOVE 0
#define GAME_MODE_RANDOM 1

#define GAMESTATE_GAME_TITLE 0
#define GAMESTATE_GAME_LEVELNAME 1
#define GAMESTATE_GAME_LOOP 2
#define GAMESTATE_GAME_OVER 3
#define GAMESTATE_GAME_COMPLETE 4
#define GAMESTATE_HISCORE_INPUT 5
#define GAMESTATE_MAIN_MENU 6
#define GAMESTATE_HISCORE_VIEW 7
#define GAMESTATE_GAME_PRELOOP 8

// FUNCS ////////////////////////////////////////////////////////////////////
#define PIXEL(var, color) var = (color); if (var[3] > 0.5) return var;

int4 unpack(float4 val)
{
    return int4(val[0] * 255, val[1] * 255, val[2] * 255, val[3] * 255);
}
int unpack(float val)
{
    return val * 255;
}
float4 pack(int4 val)
{
    return float4(val[0] / 255.0, val[1] / 255.0, val[2] / 255.0, val[3] / 255.0);
}
float4 pack(int val)
{
    return val / 255.0;
}

#define LO(v) ((v)&0xff)
#define HI(v) (((v)>>8)&0xff)
#define SLO(v) (((v)>>16)&0xff)
#define SHI(v) (((v)>>24)&0xff)
#define PACK(v) ((asuint(LO(v)))/255.0)
#define UNPACK(v) (floor((v)*255))

#define BYTE_ONE(v) ((v)&0xff)
#define BYTE_TWO(v) (((v)>>8)&0xff)
#define BYTE_THREE(v) (((v)>>16)&0xff)
#define BYTE_FOUR(v) (((v)>>24)&0xff)

bool hitbox(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2)
{
    return (x1 + w1 > x2) && (x1 < x2 + w2) && (y1 + h1 > y2) && (y1 < y2 + h2);
}
bool hitbox(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2)
{
    return (x1 + w1 >= x2) && (x1 < x2 + w2) && (y1 + h1 >= y2) && (y1 < y2 + h2);
}

// CONSTANTS ////////////////////////////////////////////////////////////////
static const float4 nullFloat4 = { 0, 0, 0, 1 };
static const float4 okayFloat4 = { 0, 0, 0, 0 };

// Standard colors.
static const float4 blackColor = { 0, 0, 0, 1 };
static const float4 whiteColor = { 1, 1, 1, 1 };
static const float4 redColor = { 255, 0, 0, 1 };
static const float4 greenColor = { 0, 255, 0, 1 };
static const float4 blueColor = { 0, 0, 255, 1 };

static const int numBullets = 3;
static const int numBadguys = 20;
static const int numWalls = 16;
static const int numKeys = 4;
static const int numTreasures = 9;
static const int numSpawners = 4;
static const int numExits = 4;

static const int gamew = 256;
static const int gameh = 128;

static const int numLevels = 30;

// MEMORY ADDRESSES /////////////////////////////////////////////////////////
#define NEW_MEMORY_SINGLE(n, a) static const int addr_##n = a;
#define NEW_MEMORY_ARRAY(n, a) static const int addr_##n = (DATA_TEX_WIDTH * a);
#define REF_MEMORY(n) (addr_##n)

#define IS_SINGLE(addr) (addr < DATA_TEX_WIDTH ? true : false)
#define IS_ARRAY(addr) (addr >= DATA_TEX_WIDTH ? true : false)

NEW_MEMORY_SINGLE(explorer_xy, 0)    // Length 1
NEW_MEMORY_SINGLE(explorer_anim, 1)  // Length 1

NEW_MEMORY_ARRAY(arr_wall_xya, 1)    // Length numWalls (16)
NEW_MEMORY_ARRAY(arr_wall_whs, 2)    // Length numWalls (16)



// MEMORY TABLE ////////////////////////////////////////////////////////////

// SINGLES /////////////////////////////////////////////////////////////////
#define SINGLE_EXPLORER_X 0
#define SINGLE_EXPLORER_Y 1
#define SINGLE_EXPLORER_DIRECTION 2
#define SINGLE_EXPLORER_FRAME 3
#define SINGLE_EXPLORER_FRAMETIME 4
#define SINGLE_EXPLORER_ACTIVE 5
#define SINGLE_EXPLORER_HEALTH 6
#define SINGLE_EXPLORER_NEXTHEALTHDECREASE 7

#define SINGLE_SPAWNX 8
#define SINGLE_SPAWNY 9
#define SINGLE_AUTOFIRETIME 10
#define SINGLE_WHITESCREENTIME 11
#define SINGLE_SCORE 12
#define SINGLE_ROLLINGSCORE 13
#define SINGLE_ROLLINGHEALTH 14
#define SINGLE_CURRENTLEVEL 15
#define SINGLE_LEVELSCOMPLETED 16
#define SINGLE_GAMETIME 17
#define SINGLE_GAMETIMETICK 18
#define SINGLE_QUITGAME 19
#define SINGLE_SCROLLX 20
#define SINGLE_SCROLLY 21
#define SINGLE_BADGUY_UPDATEDELAY 22

#define SINGLE_NEW_A 23
#define SINGLE_NEW_B 24
#define SINGLE_NEW_UP 25
#define SINGLE_NEW_LEFT 26
#define SINGLE_NEW_DOWN 27
#define SINGLE_NEW_RIGHT 28
#define SINGLE_OLD_A 29
#define SINGLE_OLD_B 30
#define SINGLE_OLD_UP 31
#define SINGLE_OLD_DOWN 32
#define SINGLE_OLD_LEFT 33
#define SINGLE_OLD_RIGHT 34

#define SINGLE_GAMEMODE 35

#define SINGLE_DEBUG_ONCE 36

#define SINGLE_WALLS_MAP 37
#define SINGLE_GAMESTATE 38
#define SINGLE_LOGIC_CLOCKTICK 80

#define SINGLE_PROMPT_ACTIVE 81
#define SINGLE_PROMPT_CURSOR 82
#define SINGLE_PROMPT_TABCOUNT 83
#define SINGLE_PROMPT_TABWIDTH 84
#define SINGLE_PROMPT_ROWS 85
#define SINGLE_PROMPT_INPUTBUFFERLENGTH 86

#define SINGLE_RECORDS_DISCOVERED 87
#define SINGLE_RECORDS_VALID 88

// ROWS ////////////////////////////////////////////////////////////////////
#define ROW_SINGLE_VARS 0
#define ROW_WALL_XYA 1
#define ROW_WALL_WHS 2
#define ROW_BADGUY_XY 3

#define ROW_SINGLE 0

#define ROW_BADGUY_X 1
#define ROW_BADGUY_Y 2
#define ROW_BADGUY_ACTIVE 3

#define ROW_BULLET_X 4
#define ROW_BULLET_Y 5
#define ROW_BULLET_VX 6
#define ROW_BULLET_VY 7
#define ROW_BULLET_LIFETIME 8
#define ROW_BULLET_ACTIVE 9

#define ROW_EXIT_X 10
#define ROW_EXIT_Y 11
#define ROW_EXIT_DEST 12
#define ROW_EXIT_ACTIVE 13

#define ROW_KEY_X 14
#define ROW_KEY_Y 15
#define ROW_KEY_TARGET 16
#define ROW_KEY_ACTIVE 17

#define ROW_SPAWNER_X 18
#define ROW_SPAWNER_Y 19
#define ROW_SPAWNER_ACTIVE 20
#define ROW_SPAWNER_SPAWNDELAY 21
#define ROW_SPAWNER_HEALTH 22

#define ROW_TREASURE_X 23
#define ROW_TREASURE_Y 24
#define ROW_TREASURE_TYPE 25
#define ROW_TREASURE_ACTIVE 26

#define ROW_WALL_X 27
#define ROW_WALL_Y 28
#define ROW_WALL_W 29
#define ROW_WALL_H 30
#define ROW_WALL_ACTIVE 31
#define ROW_WALL_STYLE 32

#define ROW_PROMPT_INPUTBUFFER 33

#define ROW_RECORDS_TIMES 34
#define ROW_RECORDS_SCORES 35
#define ROW_RECORDS_ROOMS 36
#define ROW_RECORDS_NAME_1 37
#define ROW_RECORDS_NAME_2 38
#define ROW_RECORDS_NAME_3 49

// TYPES ////////////////////////////////////////////////////////////////////
struct BadGuy {
    int x;                   // ROW_BADGUY_X
    int y;                   // ROW_BADGUY_Y
    uint active; //bool      // ROW_BADGUY_ACTIVE
};
struct Bullet {
    int x;                   // ROW_BULLET_X
    int y;                   // ROW_BULLET_Y
    int vx;                  // ROW_BULLET_VX
    int vy;                  // ROW_BULLET_VY
    int lifetime;            // ROW_BULLET_LIFETIME
    uint active; //bool      // ROW_BULLET_ACTIVE
};
struct Exit {
    int x;                   // ROW_EXIT_X
    int y;                   // ROW_EXIT_Y
    int dest;                // ROW_EXIT_DEST
    uint active; //bool      // ROW_EXIT_ACTIVE
};
struct Explorer {
    int x;                   // SINGLE_EXPLORER_X
    int y;                   // SINGLE_EXPLORER_Y
    int direction;           // SINGLE_EXPLORER_DIRECTION
    uint frame; //bool       // SINGLE_EXPLORER_FRAME
    int frameTime;           // SINGLE_EXPLORER_FRAMETIME
    bool active;             // SINGLE_EXPLORER_ACTIVE
    int health;              // SINGLE_EXPLORER_HEALTH
    int nextHealthDecrease;  // SINGLE_EXPLORER_NEXTHEALTHDECREASE
};
struct Key {
    int x;                   // ROW_KEY_X
    int y;                   // ROW_KEY_Y
    uint target; //uchar     // ROW_KEY_TARGET
    uint active; //bool      // ROW_KEY_ACTIVE
};
struct Spawner {
    int x;                   // ROW_SPAWNER_X
    int y;                   // ROW_SPAWNER_Y
    uint active; //bool      // ROW_SPAWNER_ACTIVE
    int spawnDelay;          // ROW_SPAWNER_SPAWNDELAY
    int health;              // ROW_SPAWNER_HEALTH
};
struct Treasure {
    int x;                   // ROW_TREASURE_X
    int y;                   // ROW_TREASURE_Y
    int type;                // ROW_TREASURE_TYPE
    uint active; //bool      // ROW_TREASURE_ACTIVE
};
struct Wall {
    int x;                   // ROW_WALL_X
    int y;                   // ROW_WALL_Y
    int w;                   // ROW_WALL_W
    int h;                   // ROW_WALL_H
    uint active; //bool      // ROW_WALL_ACTIVE
    int style;               // ROW_WALL_STYLE
};

// New types in shader port.
#define MAX_PROMPT_INPUT_BUFFER 4
struct Prompt {
	int active; //bool                        // SINGLE_PROMPT_ACTIVE
    int cursor;								  // SINGLE_PROMPT_CURSOR
    int tabCount;							  // SINGLE_PROMPT_TABCOUNT
    int tabWidth;							  // SINGLE_PROMPT_TABWIDTH
	int rows;								  // SINGLE_PROMPT_ROWS
    int inputBufferLength;					  // SINGLE_PROMPT_INPUTBUFFERLENGTH
    int inputBuffer[MAX_PROMPT_INPUT_BUFFER]; // ROW_PROMPT_INPUTBUFFER
};
#define MAX_HIGH_SCORES 3
struct Records {
	int times[MAX_HIGH_SCORES];                           // ROW_RECORDS_TIMES
	int scores[MAX_HIGH_SCORES];                          // ROW_RECORDS_SCORES
	int rooms[MAX_HIGH_SCORES];                           // ROW_RECORDS_ROOMS
	int names[MAX_HIGH_SCORES][MAX_PROMPT_INPUT_BUFFER];  // ROW_RECORDS_NAME_1, ROW_RECORDS_NAME_2, ROW_RECORDS_NAME_3
	int roomsDiscoveredMask;                              // SINGLE_RECORDS_DISCOVERED
	int valid;                                            // SINGLE_RECORDS_VALID
};

// GLOBALS //////////////////////////////////////////////////////////////////
static Bullet bullets[3];
static BadGuy badguys[20];
static Explorer p1; // try static?
static Wall walls[16];
static Key keys[4];
static Treasure treasures[9];
static Spawner spawners[4];
static Exit exits[4];

static Prompt prompt;
static Records records;

static int spawnx; //short               // SINGLE_SPAWNX
static int spawny; //short               // SINGLE_SPAWNY
static int autoFireTime; //char       // SINGLE_AUTOFIRETIME
static int whiteScreenTime; //char       // SINGLE_WHITESCREENTIME
static uint score; //ushort           // SINGLE_SCORE
static int rollingScore; //short       // SINGLE_ROLLINGSCORE
static uint rollingHealth; //ushort   // SINGLE_ROLLINGHEALTH
static uint currentLevel; //uchar       // SINGLE_CURRENTLEVEL
static uint levelsCompleted; //uchar  // SINGLE_LEVELSCOMPLETED
static uint gameTime; //ushort           // SINGLE_GAMETIME
static int gameTimeTick; //short       // SINGLE_GAMETIMETICK
static uint quitGame; //bool           // SINGLE_QUITGAME
static int scrollx; //short           // SINGLE_SCROLLX
static int scrolly; //short           // SINGLE_SCROLLY
static int BadGuy_UpdateDelay; //char // SINGLE_BADGUY_UPDATEDELAY

static int GameMode; //uchar          // SINGLE_GAMEMODE

static int debugOnce;                 // SINGLE_DEBUG_ONCE

static int wallsMap;                  // SINGLE_WALLS_MAP

static int gameState; // SINGLE_GAMESTATE
static int logicClockTick; // SINGLE_LOGIC_CLOCKTICK

static bool new_a;        // SINGLE_NEW_A
static bool new_b;        // SINGLE_NEW_B
static bool new_up;    // SINGLE_NEW_UP
static bool new_left;  // SINGLE_NEW_LEFT
static bool new_down;  // SINGLE_NEW_DOWN
static bool new_right; // SINGLE_NEW_RIGHT
static bool old_a;        // SINGLE_OLD_A
static bool old_b;        // SINGLE_OLD_B
static bool old_up;    // SINGLE_OLD_UP
static bool old_down;  // SINGLE_OLD_DOWN
static bool old_left;  // SINGLE_OLD_LEFT
static bool old_right; // SINGLE_OLD_RIGHT


void updateInput(int inputState)
{
    old_a = new_a;
    old_b = new_b;
    old_up = new_up;
    old_down = new_down;
    old_left = new_left;
    old_right = new_right;

    new_a = inputState & 1;
    new_b = inputState & 2;
    new_left = inputState & 4;
    new_right = inputState & 8;
    new_up = inputState & 16;
    new_down = inputState & 32;

    //new_a = (joystick[3] > 0);
    //new_b = (joystick[2] > 0);
    //new_up = (joystick[1] > 0);
    //new_down = (joystick[1] < 0);
    //new_left = (joystick[0] < 0);
    //new_right = (joystick[0] > 0);
}
void tautInput()
{
    new_a = true;
    new_b = true;
    new_up = true;
    new_down = true;
    new_left = true;
    new_right = true;
}

static const unsigned int scrw = 128;
static const unsigned int scrh = 64;

// STATE ////////////////////////////////////////////////////////////////////

float4 pack_it(uint val)
{
    // Dumb bitwise placement.
    //return float4(asfloat((val & 0xff)), asfloat((val & 0xff00)>>8), asfloat((val & 0xff0000)>>16), asfloat((val & 0xff000000)>>24));

    return float4(PACK(val), PACK(HI(val)), PACK(SLO(val)), PACK(SHI(val)));
}
float4 pack_it(int val)
{
    //return float4(asfloat((val & 0xff)), asfloat((val & 0xff00) >> 8), asfloat((val & 0xff0000) >> 16), asfloat((val & 0xff000000) >> 24));
    uint us = asuint(val);
    float4 result = {(us&0xff) / 255.0, ((us>>8)&0xff) / 255.0, ((us>>16)&0xff) / 255.0, ((us>>24)&0xff) / 255.0};
    return result;
    //return float4(PACK(val), PACK(HI(val)), PACK(SLO(val)), PACK(SHI(val)));
}
int unpack_int(float4 val)
{
    //return asint(val[0]) | (asint(val[1]) << 8) | (asint(val[2]) << 16) | (asint(val[3]) << 24);
    uint a = (val[0]*255);
    uint b = ((uint)(val[1]*255)) << 8;
    uint c = ((uint)(val[2]*255)) << 16;
    uint d = ((uint)(val[3]*255)) << 24;
    uint e = (a | b | c | d);
    int f = asint(e);
    //
    ////return asint(a);
    //
    return f;
    
    
    
    //uint a = UNPACK(val[0]);
    //uint b = ((uint)UNPACK(val[1]) << 8);
    //uint c = ((uint)UNPACK(val[2]) << 16);
    //uint d = ((uint)UNPACK(val[3]) << 24);
    //return asint(a | b | c | d);
}
uint unpack_uint(float4 val)
{
    //return asuint(val[0]) | (asuint(val[1]) << 8) | (asuint(val[2]) << 16) | (asuint(val[3]) << 24);
    uint a = UNPACK(val[0]);
    uint b = ((uint)UNPACK(val[1]) << 8);
    uint c = ((uint)UNPACK(val[2]) << 16);
    uint d = ((uint)UNPACK(val[3]) << 24);
    return a | b | c | d;
}
void load_state(texture2D tex)
{
    // Load all memory values.
    //load_explorer_state(tex);
    int i;
	int j;

    p1.x = unpack_int(tex[int2(SINGLE_EXPLORER_X, ROW_SINGLE)]);
    p1.y = unpack_int(tex[int2(SINGLE_EXPLORER_Y, ROW_SINGLE)]);
    p1.direction = unpack_int(tex[int2(SINGLE_EXPLORER_DIRECTION, ROW_SINGLE)]);
    p1.frame = unpack_uint(tex[int2(SINGLE_EXPLORER_FRAME, ROW_SINGLE)]);
    p1.frameTime = unpack_int(tex[int2(SINGLE_EXPLORER_FRAMETIME, ROW_SINGLE)]);
    p1.active = unpack_int(tex[int2(SINGLE_EXPLORER_ACTIVE, ROW_SINGLE)]) > 0 ? true : false;
    p1.health = unpack_int(tex[int2(SINGLE_EXPLORER_HEALTH, ROW_SINGLE)]);
    p1.nextHealthDecrease = unpack_int(tex[int2(SINGLE_EXPLORER_NEXTHEALTHDECREASE, ROW_SINGLE)]);

    spawnx = unpack_int(tex[int2(SINGLE_SPAWNX, ROW_SINGLE)]);
    spawny = unpack_int(tex[int2(SINGLE_SPAWNY, ROW_SINGLE)]);
    autoFireTime = unpack_int(tex[int2(SINGLE_AUTOFIRETIME, ROW_SINGLE)]);
    whiteScreenTime = unpack_int(tex[int2(SINGLE_WHITESCREENTIME, ROW_SINGLE)]);
    score = unpack_uint(tex[int2(SINGLE_SCORE, ROW_SINGLE)]);
    rollingScore = unpack_int(tex[int2(SINGLE_ROLLINGSCORE, ROW_SINGLE)]);
    rollingHealth = unpack_uint(tex[int2(SINGLE_ROLLINGHEALTH, ROW_SINGLE)]);
    currentLevel = unpack_uint(tex[int2(SINGLE_CURRENTLEVEL, ROW_SINGLE)]);
    levelsCompleted = unpack_uint(tex[int2(SINGLE_LEVELSCOMPLETED, ROW_SINGLE)]);
    gameTime = unpack_uint(tex[int2(SINGLE_GAMETIME, ROW_SINGLE)]);
    gameTimeTick = unpack_int(tex[int2(SINGLE_GAMETIMETICK, ROW_SINGLE)]);
    quitGame = unpack_uint(tex[int2(SINGLE_QUITGAME, ROW_SINGLE)]);
    scrollx = unpack_int(tex[int2(SINGLE_SCROLLX, ROW_SINGLE)]);
    scrolly = unpack_int(tex[int2(SINGLE_SCROLLY, ROW_SINGLE)]);
    BadGuy_UpdateDelay = unpack_int(tex[int2(SINGLE_BADGUY_UPDATEDELAY, ROW_SINGLE)]);

    GameMode = unpack_int(tex[int2(SINGLE_GAMEMODE, ROW_SINGLE)]);
    debugOnce = unpack_int(tex[int2(SINGLE_DEBUG_ONCE, ROW_SINGLE)]);

    wallsMap = unpack_int(tex[int2(SINGLE_WALLS_MAP, ROW_SINGLE)]);
    
    gameState = unpack_int(tex[int2(SINGLE_GAMESTATE, ROW_SINGLE)]);
    logicClockTick = unpack_int(tex[int2(SINGLE_LOGIC_CLOCKTICK, ROW_SINGLE)]);

	prompt.active = unpack_int(tex[int2(SINGLE_PROMPT_ACTIVE, ROW_SINGLE)]);
	prompt.cursor = unpack_int(tex[int2(SINGLE_PROMPT_CURSOR, ROW_SINGLE)]);
	prompt.tabCount = unpack_int(tex[int2(SINGLE_PROMPT_TABCOUNT, ROW_SINGLE)]);
	prompt.tabWidth = unpack_int(tex[int2(SINGLE_PROMPT_TABWIDTH, ROW_SINGLE)]);
	prompt.rows = unpack_int(tex[int2(SINGLE_PROMPT_ROWS, ROW_SINGLE)]);
	prompt.inputBufferLength = unpack_int(tex[int2(SINGLE_PROMPT_INPUTBUFFERLENGTH, ROW_SINGLE)]);

	records.roomsDiscoveredMask = unpack_int(tex[int2(SINGLE_RECORDS_DISCOVERED, ROW_SINGLE)]);
	records.valid = unpack_int(tex[int2(SINGLE_RECORDS_VALID, ROW_SINGLE)]);

	for (i = 0; i < MAX_HIGH_SCORES; ++i)
	{
		records.times[i] = unpack_int(tex[int2(i, ROW_RECORDS_TIMES)]);
		records.scores[i] = unpack_int(tex[int2(i, ROW_RECORDS_SCORES)]);
		records.rooms[i] = unpack_int(tex[int2(i, ROW_RECORDS_ROOMS)]);
	}

	for (i = 0; i < MAX_PROMPT_INPUT_BUFFER; ++i) records.names[0][i] = unpack_int(tex[int2(i, ROW_RECORDS_NAME_1)]);
	for (i = 0; i < MAX_PROMPT_INPUT_BUFFER; ++i) records.names[1][i] = unpack_int(tex[int2(i, ROW_RECORDS_NAME_2)]);
	for (i = 0; i < MAX_PROMPT_INPUT_BUFFER; ++i) records.names[2][i] = unpack_int(tex[int2(i, ROW_RECORDS_NAME_3)]);

    new_a = (unpack_int(tex[int2(SINGLE_NEW_A, ROW_SINGLE)]) > 0 ? true : false);
    new_b = (unpack_int(tex[int2(SINGLE_NEW_B, ROW_SINGLE)]) > 0 ? true : false);
    new_up = (unpack_int(tex[int2(SINGLE_NEW_UP, ROW_SINGLE)]) > 0 ? true : false);
    new_left = (unpack_int(tex[int2(SINGLE_NEW_LEFT, ROW_SINGLE)]) > 0 ? true : false);
    new_down = (unpack_int(tex[int2(SINGLE_NEW_DOWN, ROW_SINGLE)]) > 0 ? true : false);
    new_right = (unpack_int(tex[int2(SINGLE_NEW_RIGHT, ROW_SINGLE)]) > 0 ? true : false);
    old_a = (unpack_int(tex[int2(SINGLE_OLD_A, ROW_SINGLE)]) > 0 ? true : false);
    old_b = (unpack_int(tex[int2(SINGLE_OLD_B, ROW_SINGLE)]) > 0 ? true : false);
    old_up = (unpack_int(tex[int2(SINGLE_OLD_UP, ROW_SINGLE)]) > 0 ? true : false);
    old_left = (unpack_int(tex[int2(SINGLE_OLD_DOWN, ROW_SINGLE)]) > 0 ? true : false);
    old_down = (unpack_int(tex[int2(SINGLE_OLD_LEFT, ROW_SINGLE)]) > 0 ? true : false);
    old_right = (unpack_int(tex[int2(SINGLE_OLD_RIGHT, ROW_SINGLE)]) > 0 ? true : false);

    for (i = 0; i < numBadguys; ++i)
    {
        badguys[i].x = unpack_int(tex[int2(i, ROW_BADGUY_X)]);
        badguys[i].y = unpack_int(tex[int2(i, ROW_BADGUY_Y)]);
        badguys[i].active = unpack_uint(tex[int2(i, ROW_BADGUY_ACTIVE)]);
    }
    for (i = 0; i < numBullets; ++i)
    {
        bullets[i].x = unpack_int(tex[int2(i, ROW_BULLET_X)]);
        bullets[i].y = unpack_int(tex[int2(i, ROW_BULLET_Y)]);
        bullets[i].vx = unpack_int(tex[int2(i, ROW_BULLET_VX)]);
        bullets[i].vy = unpack_int(tex[int2(i, ROW_BULLET_VY)]);
        bullets[i].lifetime = unpack_int(tex[int2(i, ROW_BULLET_LIFETIME)]);
        bullets[i].active = unpack_uint(tex[int2(i, ROW_BULLET_ACTIVE)]);
    }
    for (i = 0; i < numExits; ++i)
    {
        exits[i].x = unpack_int(tex[int2(i, ROW_EXIT_X)]);
        exits[i].y = unpack_int(tex[int2(i, ROW_EXIT_Y)]);
        exits[i].dest = unpack_int(tex[int2(i, ROW_EXIT_DEST)]);
        exits[i].active = unpack_int(tex[int2(i, ROW_EXIT_ACTIVE)]);
    }
    for (i = 0; i < numKeys; ++i)
    {
        keys[i].x = unpack_int(tex[int2(i, ROW_KEY_X)]);
        keys[i].y = unpack_int(tex[int2(i, ROW_KEY_Y)]);
        keys[i].target = unpack_uint(tex[int2(i, ROW_KEY_TARGET)]);
        keys[i].active = unpack_uint(tex[int2(i, ROW_KEY_ACTIVE)]);
    }
    for (i = 0; i < numSpawners; ++i)
    {
        spawners[i].x = unpack_int(tex[int2(i, ROW_SPAWNER_X)]);
        spawners[i].y = unpack_int(tex[int2(i, ROW_SPAWNER_Y)]);
        spawners[i].active = unpack_uint(tex[int2(i, ROW_SPAWNER_ACTIVE)]);
        spawners[i].spawnDelay = unpack_int(tex[int2(i, ROW_SPAWNER_SPAWNDELAY)]);
        spawners[i].health = unpack_int(tex[int2(i, ROW_SPAWNER_HEALTH)]);
    }
    for (i = 0; i < numTreasures; ++i)
    {
        treasures[i].x = unpack_int(tex[int2(i, ROW_TREASURE_X)]);
        treasures[i].y = unpack_int(tex[int2(i, ROW_TREASURE_Y)]);
        treasures[i].type = unpack_int(tex[int2(i, ROW_TREASURE_TYPE)]);
        treasures[i].active = unpack_uint(tex[int2(i, ROW_TREASURE_ACTIVE)]);
    }
    for (i = 0; i < numWalls; ++i)
    {
        walls[i].x = unpack_int(tex[int2(i, ROW_WALL_X)]);
        walls[i].y = unpack_int(tex[int2(i, ROW_WALL_Y)]);
        walls[i].w = unpack_int(tex[int2(i, ROW_WALL_W)]);
        walls[i].h = unpack_int(tex[int2(i, ROW_WALL_H)]);
        walls[i].active = unpack_int(tex[int2(i, ROW_WALL_ACTIVE)]);
        walls[i].style = unpack_int(tex[int2(i, ROW_WALL_STYLE)]);
    }
	for (i = 0; i < MAX_PROMPT_INPUT_BUFFER; ++i)
	{
		prompt.inputBuffer[i] = unpack_int(tex[int2(i, ROW_PROMPT_INPUTBUFFER)]);
	}
}

float4 save_ExplorerX()
{
    return pack_it(p1.x);
}
float4 save_ExplorerY()
{
    return pack_it(p1.y);
}
float4 save_ExplorerDirection()
{
    return pack_it(p1.direction);
}
float4 save_ExplorerFrame()
{
    return pack_it(p1.frame);
}
float4 save_ExplorerFrametime()
{
    return pack_it(p1.frameTime);
}
float4 save_ExplorerActive()
{
    return pack_it((uint)(p1.active ? 1 : 0));
}
float4 save_ExplorerHealth()
{
    return pack_it(p1.health);
}
float4 save_ExplorerNextHealthDecrease()
{
    return pack_it(p1.nextHealthDecrease);
}
float4 save_SpawnX()
{
    return pack_it(spawnx);
}
float4 save_SpawnY()
{
    return pack_it(spawny);
}
float4 save_AutoFireTime()
{
    return pack_it(autoFireTime);
}
float4 save_WhiteScreenTime()
{
    return pack_it(whiteScreenTime);
}
float4 save_Score()
{
    return pack_it(score);
}
float4 save_RollingScore()
{
    return pack_it(rollingScore);
}
float4 save_RollingHealth()
{
    return pack_it(rollingHealth);
}
float4 save_CurrentLevel()
{
    return pack_it(currentLevel);
}
float4 save_LevelsCompleted()
{
    return pack_it(levelsCompleted);
}
float4 save_GameTime()
{
    return pack_it(gameTime);
}
float4 save_GameTimeTick()
{
    return pack_it(gameTimeTick);
}
float4 save_QuitGame()
{
    return pack_it(quitGame);
}
float4 save_ScrollX()
{
    return pack_it(scrollx);
}
float4 save_ScrollY()
{
    return pack_it(scrolly);
}
float4 save_Badguy_UpdateDelay()
{
    return pack_it(BadGuy_UpdateDelay);
}
float4 save_GameMode()
{
    return pack_it(GameMode);
}
float4 save_DebugOnce()
{
    return pack_it(debugOnce);
}
float4 save_WallsMap()
{
    return pack_it(wallsMap);
}
float4 save_GameState()
{
    return pack_it(gameState);
}
float4 save_LogicClockTick()
{
    return pack_it(logicClockTick);
}
float4 save_NewA()
{
    return pack_it((uint)(new_a ? 1 : 0));
}
float4 save_NewB()
{
    return pack_it((uint)(new_b ? 1 : 0));
}
float4 save_NewUp()
{
    return pack_it((uint)(new_up ? 1 : 0));
}
float4 save_NewLeft()
{
    return pack_it((uint)(new_left ? 1 : 0));
}
float4 save_NewDown()
{
    return pack_it((uint)(new_down ? 1 : 0));
}
float4 save_NewRight()
{
    return pack_it((uint)(new_right ? 1 : 0));
}
float4 save_OldA()
{
    return pack_it((uint)(old_a ? 1 : 0));
}
float4 save_OldB()
{
    return pack_it((uint)(old_b ? 1 : 0));
}
float4 save_OldUp()
{
    return pack_it((uint)(old_up ? 1 : 0));
}
float4 save_OldDown()
{
    return pack_it((uint)(old_down ? 1 : 0));
}
float4 save_OldLeft()
{
    return pack_it((uint)(old_left ? 1 : 0));
}
float4 save_OldRight()
{
    return pack_it((uint)(old_right ? 1 : 0));
}
float4 save_PromptActive()
{
	return pack_it(prompt.active);
}
float4 save_PromptCursor()
{
	return pack_it(prompt.cursor);
}
float4 save_PromptTabCount()
{
	return pack_it(prompt.tabCount);
}
float4 save_PromptTabWidth()
{
	return pack_it(prompt.tabWidth);
}
float4 save_PromptRows()
{
	return pack_it(prompt.rows);
}
float4 save_PromptInputBufferLength()
{
	return pack_it(prompt.inputBufferLength);
}
float4 save_RecordsRoomsDiscoveredMask()
{
	return pack_it(records.roomsDiscoveredMask);
}
float4 save_RecordsValid()
{
	return pack_it(records.valid);
}

float4 save_Single(int x)
{
    switch (x)
    {
    case SINGLE_EXPLORER_X: return save_ExplorerX();
    case SINGLE_EXPLORER_Y: return save_ExplorerY();
    case SINGLE_EXPLORER_DIRECTION: return save_ExplorerDirection();
    case SINGLE_EXPLORER_FRAME: return save_ExplorerFrame();
    case SINGLE_EXPLORER_FRAMETIME: return save_ExplorerFrametime();
    case SINGLE_EXPLORER_ACTIVE: return save_ExplorerActive();
    case SINGLE_EXPLORER_HEALTH: return save_ExplorerHealth();
    case SINGLE_EXPLORER_NEXTHEALTHDECREASE: return save_ExplorerNextHealthDecrease();

    case SINGLE_SPAWNX: return save_SpawnX();
    case SINGLE_SPAWNY: return save_SpawnY();
    case SINGLE_AUTOFIRETIME: return save_AutoFireTime();
    case SINGLE_WHITESCREENTIME: return save_WhiteScreenTime();
    case SINGLE_SCORE: return save_Score();
    case SINGLE_ROLLINGSCORE: return save_RollingScore();
    case SINGLE_ROLLINGHEALTH: return save_RollingHealth();
    case SINGLE_CURRENTLEVEL: return save_CurrentLevel();
    case SINGLE_LEVELSCOMPLETED: return save_LevelsCompleted();
    case SINGLE_GAMETIME: return save_GameTime();
    case SINGLE_GAMETIMETICK: return save_GameTimeTick();
    case SINGLE_QUITGAME: return save_QuitGame();
    case SINGLE_SCROLLX: return save_ScrollX();
    case SINGLE_SCROLLY: return save_ScrollY();
    case SINGLE_BADGUY_UPDATEDELAY: return save_Badguy_UpdateDelay();

    case SINGLE_NEW_A: return save_NewA();
    case SINGLE_NEW_B: return save_NewB();
    case SINGLE_NEW_UP: return save_NewUp();
    case SINGLE_NEW_LEFT: return save_NewLeft();
    case SINGLE_NEW_DOWN: return save_NewDown();
    case SINGLE_NEW_RIGHT: return save_NewRight();
    case SINGLE_OLD_A: return save_OldA();
    case SINGLE_OLD_B: return save_OldB();
    case SINGLE_OLD_UP: return save_OldUp();
    case SINGLE_OLD_DOWN: return save_OldDown();
    case SINGLE_OLD_LEFT: return save_OldLeft();
    case SINGLE_OLD_RIGHT: return save_OldRight();

	case SINGLE_PROMPT_ACTIVE: return save_PromptActive();
	case SINGLE_PROMPT_CURSOR: return save_PromptCursor();
	case SINGLE_PROMPT_TABCOUNT: return save_PromptTabCount();
	case SINGLE_PROMPT_TABWIDTH: return save_PromptTabWidth();
	case SINGLE_PROMPT_ROWS: return save_PromptRows();
	case SINGLE_PROMPT_INPUTBUFFERLENGTH: return save_PromptInputBufferLength();

    case SINGLE_GAMEMODE: return save_GameMode();

    case SINGLE_DEBUG_ONCE: return save_DebugOnce();

    case SINGLE_WALLS_MAP: return save_WallsMap();
    
    case SINGLE_GAMESTATE: return save_GameState();
    case SINGLE_LOGIC_CLOCKTICK: return save_LogicClockTick();

	case SINGLE_RECORDS_DISCOVERED: return save_RecordsRoomsDiscoveredMask();
	case SINGLE_RECORDS_VALID: return save_RecordsValid();
    }
    return nullFloat4;
}
float4 save_BadguyX(int id)
{
    if (id >= numBadguys) return nullFloat4;
    return pack_it(badguys[id].x);
}
float4 save_BadguyY(int id)
{
    if (id >= numBadguys) return nullFloat4;
    return pack_it(badguys[id].y);
}
float4 save_BadguyActive(int id)
{
    if (id >= numBadguys) return nullFloat4;
    return pack_it(badguys[id].active);
}
float4 save_BulletX(int id)
{
    if (id >= numBullets) return nullFloat4;
    return pack_it(bullets[id].x);
}
float4 save_BulletY(int id)
{
    if (id >= numBullets) return nullFloat4;
    return pack_it(bullets[id].y);
}
float4 save_BulletVX(int id)
{
    if (id >= numBullets) return nullFloat4;
    return pack_it(bullets[id].vx);
}
float4 save_BulletVY(int id)
{
    if (id >= numBullets) return nullFloat4;
    return pack_it(bullets[id].vy);
}
float4 save_BulletLifetime(int id)
{
    if (id >= numBullets) return nullFloat4;
    return pack_it(bullets[id].lifetime);
}
float4 save_BulletActive(int id)
{
    if (id >= numBullets) return nullFloat4;
    return pack_it(bullets[id].active);
}
float4 save_ExitX(int id)
{
    if (id >= numExits) return nullFloat4;
    return pack_it(exits[id].x);
}
float4 save_ExitY(int id)
{
    if (id >= numExits) return nullFloat4;
    return pack_it(exits[id].y);
}
float4 save_ExitDest(int id)
{
    if (id >= numExits) return nullFloat4;
    return pack_it(exits[id].dest);
}
float4 save_ExitActive(int id)
{
    if (id >= numExits) return nullFloat4;
    return pack_it(exits[id].active);
}
float4 save_KeyX(int id)
{
    if (id >= numKeys) return nullFloat4;
    return pack_it(keys[id].x);
}
float4 save_KeyY(int id)
{
    if (id >= numKeys) return nullFloat4;
    return pack_it(keys[id].y);
}
float4 save_KeyDest(int id)
{
    if (id >= numKeys) return nullFloat4;
    return pack_it(keys[id].target);
}
float4 save_KeyActive(int id)
{
    if (id >= numKeys) return nullFloat4;
    return pack_it(keys[id].active);
}
float4 save_SpawnerX(int id)
{
    if (id >= numSpawners) return nullFloat4;
    return pack_it(spawners[id].x);
}
float4 save_SpawnerY(int id)
{
    if (id >= numSpawners) return nullFloat4;
    return pack_it(spawners[id].y);
}
float4 save_SpawnerActive(int id)
{
    if (id >= numSpawners) return nullFloat4;
    return pack_it(spawners[id].active);
}
float4 save_SpawnerSpawnDelay(int id)
{
    if (id >= numSpawners) return nullFloat4;
    return pack_it(spawners[id].spawnDelay);
}
float4 save_SpawnerHealth(int id)
{
    if (id >= numSpawners) return nullFloat4;
    return pack_it(spawners[id].health);
}
float4 save_TreasureX(int id)
{
    if (id >= numTreasures) return nullFloat4;
    return pack_it(treasures[id].x);
}
float4 save_TreasureY(int id)
{
    if (id >= numTreasures) return nullFloat4;
    return pack_it(treasures[id].y);
}
float4 save_TreasureType(int id)
{
    if (id >= numTreasures) return nullFloat4;
    return pack_it(treasures[id].type);
}
float4 save_TreasureActive(int id)
{
    if (id >= numTreasures) return nullFloat4;
    return pack_it(treasures[id].active);
}
float4 save_WallX(int id)
{
    if (id >= numWalls) return nullFloat4;
    return pack_it(walls[id].x);
}
float4 save_WallY(int id)
{
    if (id >= numWalls) return nullFloat4;
    return pack_it(walls[id].y);
}
float4 save_WallW(int id)
{
    if (id >= numWalls) return nullFloat4;
    return pack_it(walls[id].w);
}
float4 save_WallH(int id)
{
    if (id >= numWalls) return nullFloat4;
    return pack_it(walls[id].h);
}
float4 save_WallActive(int id)
{
    if (id >= numWalls) return nullFloat4;
    return pack_it(walls[id].active);
}
float4 save_WallStyle(int id)
{
    if (id >= numWalls) return nullFloat4;
    return pack_it(walls[id].style);
}
float4 save_PromptInputBuffer(int id)
{
	if (id >= MAX_PROMPT_INPUT_BUFFER) return nullFloat4;
	return pack_it(prompt.inputBuffer[id]);
}
float4 save_RecordsTimes(int id)
{
	if (id >= MAX_HIGH_SCORES) return nullFloat4;
	return pack_it(records.times[id]);
}
float4 save_RecordsScores(int id)
{
	if (id >= MAX_HIGH_SCORES) return nullFloat4;
	return pack_it(records.scores[id]);
}
float4 save_RecordsRooms(int id)
{
	if (id >= MAX_HIGH_SCORES) return nullFloat4;
	return pack_it(records.rooms[id]);
}
float4 save_RecordsName1(int id)
{
	if (id >= MAX_PROMPT_INPUT_BUFFER) return nullFloat4;
	return pack_it(records.names[0][id]);
}
float4 save_RecordsName2(int id)
{
	if (id >= MAX_PROMPT_INPUT_BUFFER) return nullFloat4;
	return pack_it(records.names[1][id]);
}
float4 save_RecordsName3(int id)
{
	if (id >= MAX_PROMPT_INPUT_BUFFER) return nullFloat4;
	return pack_it(records.names[2][id]);
}

float4 save_state(int x, int y)
{
    switch (y)
    {
    case ROW_SINGLE: return save_Single(x);
    case ROW_BADGUY_X: return save_BadguyX(x);
    case ROW_BADGUY_Y: return save_BadguyY(x);
    case ROW_BADGUY_ACTIVE: return save_BadguyActive(x);
    case ROW_BULLET_X: return save_BulletX(x);
    case ROW_BULLET_Y: return save_BulletY(x);
    case ROW_BULLET_VX: return  save_BulletVX(x);
    case ROW_BULLET_VY: return save_BulletVY(x);
    case ROW_BULLET_LIFETIME: return save_BulletLifetime(x);
    case ROW_BULLET_ACTIVE: return save_BulletActive(x);

    case ROW_EXIT_X: return save_ExitX(x);
    case ROW_EXIT_Y: return save_ExitY(x);
    case ROW_EXIT_DEST: return save_ExitDest(x);
    case ROW_EXIT_ACTIVE: return save_ExitActive(x);

    case ROW_KEY_X: return save_KeyX(x);
    case ROW_KEY_Y: return save_KeyY(x);
    case ROW_KEY_TARGET: return save_KeyDest(x);
    case ROW_KEY_ACTIVE: return save_KeyActive(x);

    case ROW_SPAWNER_X: return save_SpawnerX(x);
    case ROW_SPAWNER_Y: return save_SpawnerY(x);
    case ROW_SPAWNER_ACTIVE: return save_SpawnerActive(x);
    case ROW_SPAWNER_SPAWNDELAY: return save_SpawnerSpawnDelay(x);
    case ROW_SPAWNER_HEALTH: return save_SpawnerHealth(x);

    case ROW_TREASURE_X: return save_TreasureX(x);
    case ROW_TREASURE_Y: return save_TreasureY(x);
    case ROW_TREASURE_TYPE: return save_TreasureType(x);
    case ROW_TREASURE_ACTIVE: return save_TreasureActive(x);

    case ROW_WALL_X: return save_WallX(x);
    case ROW_WALL_Y: return save_WallY(x);
    case ROW_WALL_W: return save_WallW(x);
    case ROW_WALL_H: return save_WallH(x);
    case ROW_WALL_ACTIVE: return save_WallActive(x);
    case ROW_WALL_STYLE: return save_WallStyle(x);

	case ROW_PROMPT_INPUTBUFFER: return save_PromptInputBuffer(x);

	case ROW_RECORDS_TIMES: return save_RecordsTimes(x);
	case ROW_RECORDS_SCORES: return save_RecordsScores(x);
	case ROW_RECORDS_ROOMS: return save_RecordsRooms(x);
	case ROW_RECORDS_NAME_1: return save_RecordsName1(x);
	case ROW_RECORDS_NAME_2: return save_RecordsName2(x);
	case ROW_RECORDS_NAME_3: return save_RecordsName3(x);
    }

    return nullFloat4;
}

// RECORDS ///////////////////////////////////////////////////////////////////
int getRoomClearPercentage()
{
	int i;
	int block;
	int completed = 0;

	if (!records.valid) return 0;

	//for (char blockNum = 0; blockNum < 5; ++blockNum) {
	block = records.roomsDiscoveredMask;
	for (i = 0; i < 32; ++i) {
		if ((block >> i) & 1) completed++;
	}
	//}
	return (completed * 100) / 30;
}


#endif

