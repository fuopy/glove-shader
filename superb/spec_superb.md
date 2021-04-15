# Superb Spec!


Udon#
Input Shader
Logic Shader
Render Shader

### Network Udon Sharp
- Update logic driven by lower layer's clock generator.
- Polls the current controller state.
- Stamps the controller state with the current frame, based on the lower layer's `currentExternalFrame' value.
- Negotiates whether the game client is a Master or a Peer role. (See procedures and roles section below.)


## Input Shader
- Generates the master game clock
- Forwards input data to the Logic Shader

### Contract: Expose current frame number.
The current frame number is exposed in the `currentExternalFrame` value.

## Logic Shader
- Accepts inputs and plays them as-is. No knowledge of above or below layers, just uses data given.

### Contract: Advance a frame.
To advance a Logic Shader frame, toggle the `clockTick` value. `clockTick` should toggle between `SIGNAL_ON` and `SIGNAL_OFF`.
When the frame is advanced, the Logic Shader will poll `nextInputState`, which has the controller state to use for that frame.

### Contract: Snapshot game state.
To copy the game state over the network, the Logic Shader can be frozen by an upper layer, and the colors can be sampled by
an upper layer.

## Render Shader
- Renders a scene based on memory values in Logic Shader.


# Network Strategy
- Master broadcasts (frame#, input).
- Peers maintain a list of frames from master. If there is a valid frame to advance to, peers execute at `CLOCK_SPEED` until frame#, then change input. Otherwise, peers are paused.
- Master always executes at CLOCK_SPEED.



[ Processing ] ---- No more frames available -----> [ Paused ]
        <--- Next frame becomes available -------

Alg: AreFramesAvailable().
- List of frames `L`
- current frame number `f`





### RANDOM FAQ

0: What are Bingo and Dingo?
   Bingo = BST = Bulk State Transfer.
   Dingo = DST = Delta State Transfer.
   I think Bingus and Dingus are appropriate, too.

1. Where is the clock generated?
A: The system runs at a fixed frequency of 60 Hz. The lobby Master will always perform a local
   frame advance at 60 Hz. Peers will frame advance at 60 Hz, but only if there is buffered
   delta state available to consume.

   The clock is generated in Udon through a VRC-provided variable, synchronized among peers,
   named: `getservertimeinseconds`.

   I'm unsure whether a local Update() is called at a guaranteed minimum rate of at least 60 Hz.
   So there will be a way of queuing up double logic updates. This logic path will be used not
   only for slowdown or slow machines, but also for pretty much any environment where Update()
   is called at a rate not divisible by 60 Hz.

2. How does a bulk state transfer work?
A: The Bulk State Transfer procedure begins when a new player joins the lobby. There may be other
   conditions that begin this procedure, but for now let's just focus on this one.

   The purpose of the Bulk State Transfer is to bring all peers' simulation states to be exactly
   the same. This is done by pausing local simulations everywhere, copying the bytes of the Master's
   simulation, sending those bytes over the network to peers, having the peers install the bytes,
   and finally resuming normal operation.

   One challenge of the implementation of BST is that I'm not sure how much bandwidth I can transfer
   before hitting a deathrun. If it ends up being so strict that it takes longer than a frame, I might
   have to sneak in BST as a sort of "delayed" / "simultaneous" procedure, along with Delta State Tx.

   Delta State Transfer only transmits a maximum of 60 bytes per second. This is well within the
   ~200 bytes-per-serialization that VRC allows in a world. If I were to multiplex our transfer so
   that we do both Bingo and Dingo, we might end up being able to ... [TBD: Calculate Math]

3. How many variables/arrays exist to transfer?
A: Right now, everything is done by hand. I copy from the HLSL header files to the CS files all of
   the arrays as well as their lengths. Ideally in the future I might have some sort of helpful
   preprocessor generate these lines, as well as the rest of the support code for saving/loading
   state in the local shader CustomRenderTexture.

   Only the Lower shared variables need to be transfered during Bingo. See Appendix A for calculation
   of bytes needed for Bingo procedure.

   1K and 132 bytes are needed for BST. A single serialization can have ~200 bytes. ...Yeah.

   I do not want to have the host's game lag when a new player joins. (Even though VRC will lag.)
   I at least want to make it so the game engine is capable of robustly and cleanly sharing the
   BST because then it'll be easy to implement other scenarios, such as when a person walks up
   to a new arcade cab that someone else is playing. Say there's two cabs in a map. It'll kill the
   bandwidth to have both visible to a player. But I bet we can have it work if you can only look
   at one at a time.

   Anyway, when a peer In-Ranges a Master's cab, that means they'll start the procedure for
   downloading the full state data. I think we can have it so that an initiate message is sent
   from the peer...? [TODO: REVISIT THIS QUESTION. NOT SURE IF IT ACTUALLY MATTERS]




Appendix A: Calculation of memory needed for Bingo.

```c
static Bullet bullets[3]; * 5 fields = 15 values
static BadGuy badguys[20]; * 3 fields = 60 values
static Explorer p1; // try static? * 8 fields. = 8 values
static Wall walls[16]; * 6 fields = 96 values
static Key keys[4]; * 4 fields = 16 values
static Treasure treasures[9]; * 4 fields = 36 values
static Spawner spawners[4]; * 5 fields = 20 values
static Exit exits[4]; * 4 fields. = 16 values

Sum of structs:
267 values.

Single values:
static int spawnx; //short			   // SINGLE_SPAWNX
static int spawny; //short			   // SINGLE_SPAWNY
static int autoFireTime; //char	   // SINGLE_AUTOFIRETIME
static int whiteScreenTime; //char	   // SINGLE_WHITESCREENTIME
static uint score; //ushort		   // SINGLE_SCORE
static int rollingScore; //short	   // SINGLE_ROLLINGSCORE
static uint rollingHealth; //ushort   // SINGLE_ROLLINGHEALTH
static uint currentLevel; //uchar	   // SINGLE_CURRENTLEVEL
static uint levelsCompleted; //uchar  // SINGLE_LEVELSCOMPLETED
static uint gameTime; //ushort		   // SINGLE_GAMETIME
static int gameTimeTick; //short	   // SINGLE_GAMETIMETICK
static uint quitGame; //bool		   // SINGLE_QUITGAME
static int scrollx; //short		   // SINGLE_SCROLLX
static int scrolly; //short		   // SINGLE_SCROLLY
static int BadGuy_UpdateDelay; //char // SINGLE_BADGUY_UPDATEDELAY

static int GameMode; //uchar          // SINGLE_GAMEMODE
static int debugOnce;                 // SINGLE_DEBUG_ONCE
static int wallsMap;                  // SINGLE_WALLS_MAP
static int gameState; // SINGLE_GAMESTATE
static int logicClockTick; // SINGLE_LOGIC_CLOCKTICK

static bool new_a;	    // SINGLE_NEW_A
static bool new_b;	    // SINGLE_NEW_B
static bool new_up;    // SINGLE_NEW_UP
static bool new_left;  // SINGLE_NEW_LEFT
static bool new_down;  // SINGLE_NEW_DOWN
static bool new_right; // SINGLE_NEW_RIGHT
static bool old_a;	    // SINGLE_OLD_A
static bool old_b;	    // SINGLE_OLD_B
static bool old_up;    // SINGLE_OLD_UP
static bool old_down;  // SINGLE_OLD_DOWN
static bool old_left;  // SINGLE_OLD_LEFT
static bool old_right; // SINGLE_OLD_RIGHT

Sum of singles:
22 single values.

Total sum:
289 values.

Valus are stored as Ints, so...
289 * 4 = 1156 bytes. AKA 1K and 132 bytes.
```



