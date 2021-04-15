#ifndef _SUPERB_UPPERSHARED_HLSL_
#define _SUPERB_UPPERSHARED_HLSL_


// DEFINES //////////////////////////////////////////////////////////////////
#define DATA_TEX_WIDTH 256
#define DATA_TEX_HEIGHT 256


#define SIGNAL_ON 65280
#define SIGNAL_OFF 0


// TODO: remove these silly macros
#define PACK2(v) ((asuint(LO2(v)))/255.0)
#define LO2(v) ((v)&0xff)
#define HI2(v) (((v)>>8)&0xff)
#define SLO2(v) (((v)>>16)&0xff)
#define SHI2(v) (((v)>>24)&0xff)
#define UNPACK2(v) (floor((v)*255))
float4 pack_upper_it(uint val)
{
	return float4(PACK2(val), PACK2(HI2(val)), PACK2(SLO2(val)), PACK2(SHI2(val)));
}
float4 pack_upper_it(int val)
{
	uint us = asuint(val);
	float4 result = { (us & 0xff) / 255.0, ((us >> 8) & 0xff) / 255.0, ((us >> 16) & 0xff) / 255.0, ((us >> 24) & 0xff) / 255.0 };
	return result;
}
int unpack_upper_int(float4 val)
{
	uint a = (val[0] * 255);
	uint b = ((uint)(val[1] * 255)) << 8;
	uint c = ((uint)(val[2] * 255)) << 16;
	uint d = ((uint)(val[3] * 255)) << 24;
	uint e = (a | b | c | d);
	int f = asint(e);
	return f;
}
uint unpack_upper_uint(float4 val)
{
	uint a = UNPACK2(val[0]);
	uint b = ((uint)UNPACK2(val[1]) << 8);
	uint c = ((uint)UNPACK2(val[2]) << 16);
	uint d = ((uint)UNPACK2(val[3]) << 24);
	return a | b | c | d;
}


// MEMORY TABLE ////////////////////////////////////////////////////////////

// SINGLES /////////////////////////////////////////////////////////////////
#define SINGLE_UPPER_CLOCKTICK 0
#define SINGLE_UPPER_NEXTINPUTSTATE 1
#define SINGLE_UPPER_MOSTRECENTPROCESSEDFRAME 2
#define SINGLE_UPPER_CURRENTFRAME 3
#define SINGLE_UPPER_CAUGHTUP 4
#define SINGLE_UPPER_UPPERNETCLOCK 5

#define ROW_UPPER_SINGLE 0


// GLOBALS //////////////////////////////////////////////////////////////////
static int clockTick;
static int nextInputState;
static int mostRecentProcessedFrame;
static int currentFrame;
static int caughtUp;
static int upperNetClock;

void load_upper_state(texture2D tex)
{
	clockTick = unpack_upper_int(tex[int2(SINGLE_UPPER_CLOCKTICK, ROW_UPPER_SINGLE)]);
	nextInputState = unpack_upper_int(tex[int2(SINGLE_UPPER_NEXTINPUTSTATE, ROW_UPPER_SINGLE)]);
	mostRecentProcessedFrame = unpack_upper_int(tex[int2(SINGLE_UPPER_MOSTRECENTPROCESSEDFRAME, ROW_UPPER_SINGLE)]);
	currentFrame = unpack_upper_int(tex[int2(SINGLE_UPPER_CURRENTFRAME, ROW_UPPER_SINGLE)]);
	caughtUp = unpack_upper_int(tex[int2(SINGLE_UPPER_CAUGHTUP, ROW_UPPER_SINGLE)]);
	upperNetClock = unpack_upper_int(tex[int2(SINGLE_UPPER_UPPERNETCLOCK, ROW_UPPER_SINGLE)]);
}

float4 saveUpper_ClockTick()
{
	return pack_upper_it(clockTick);
}

float4 saveUpper_NextInputState()
{
	return pack_upper_it(nextInputState);
}

float4 saveUpper_MostRecentProcessedFrame()
{
	return pack_upper_it(mostRecentProcessedFrame);
}

float4 saveUpper_CurrentFrame()
{
	return pack_upper_it(currentFrame);
}

float4 saveUpper_CaughtUp()
{
	return pack_upper_it(caughtUp);
}

float4 saveUpper_UpperNetClock()
{
	return pack_upper_it(upperNetClock);
}

float4 save_UpperSingle(int x)
{
	switch (x)
	{
	case SINGLE_UPPER_CLOCKTICK: return saveUpper_ClockTick();
	case SINGLE_UPPER_NEXTINPUTSTATE: return saveUpper_NextInputState();
	case SINGLE_UPPER_MOSTRECENTPROCESSEDFRAME: return saveUpper_MostRecentProcessedFrame();
	case SINGLE_UPPER_CURRENTFRAME: return saveUpper_CurrentFrame();
	case SINGLE_UPPER_CAUGHTUP: return saveUpper_CaughtUp();
	case SINGLE_UPPER_UPPERNETCLOCK: return saveUpper_UpperNetClock();
	}
	return float4(0, 0, 0, 0);
}

float4 save_upper_state(int x, int y)
{
	switch (y)
	{
	case ROW_UPPER_SINGLE: return save_UpperSingle(x);
	}
	return float4(0, 0, 0, 0);
}


#endif