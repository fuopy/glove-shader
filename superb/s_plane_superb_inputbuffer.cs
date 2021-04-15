using System;
using UdonSharp;
using UnityEngine;
using UnityEngine.UI;
using VRC.SDKBase;
using VRC.Udon;
using System.Collections.Generic;

public class s_plane_superb_inputbuffer : UdonSharpBehaviour
{
    public Material renderMaterial;
    public Material gameLogicMaterial;
    public Material gameRenderMaterial;
    
    public Text debugText;
    public Text debugText2;

    // COMMUNICATION: CONSTANTS AND GLOBALS //////////////////////////////////
    // Communication Module: State names.
    const int COMMUNICATION_STATE_UNINITIALIZED = 0;
    const int COMMUNICATION_STATE_MASTER = 1;
    const int COMMUNICATION_STATE_PEER = 2;

    // Communication Module: Command names.
    const int COMMUNICATION_MIDI_COMMAND_IDENTIFY = 0;
    const int COMMUNICATION_MIDI_COMMAND_PING = 1;

    // Communication Module: Current operating state.
    private int Communication_CurrentState;

    // Communication Module: Current index in circular buffer.
    private int Communication_CurrentBufferIndex;
    private int Communication_CurrentStateIndex;

    // Communication Module: Current frame number.
    private int Communication_CurrentFrameNumber;

    // Communication Module: Previous input state.
    private int Communication_PreviousInputState;

    // Communication Module: Input command queue.
    const int Communication_PeerInputCommandQueueLength = 128;
    private int[] Communication_PeerInputCommandQueue = new int[Communication_PeerInputCommandQueueLength];
    private int Communication_PeerInputCommandQueueHead;
    private int Communication_PeerInputCommandQueueTail;

    // Communication Module: Clock tick toggle.
    private int Communication_ClockTick;

    // Communication Module: Master Heart Beat, used for sending repeats to update peer sims when no input delta.
    private int Communication_MasterHeartBeat;

    // Communication Module: Peer Additional Delay, used to add extra delay in case the peer runs behind.
    private int Communication_PeerAdditonalDelay;

    // Communication Module: Over-the-network values.
    [UdonSynced] public int Communication_SyncedBuffer_00;
    [UdonSynced] public int Communication_SyncedBuffer_01;
    [UdonSynced] public int Communication_SyncedBuffer_02;
    [UdonSynced] public int Communication_SyncedBuffer_03;
    [UdonSynced] public int Communication_SyncedBuffer_04;
    [UdonSynced] public int Communication_SyncedBuffer_05;
    [UdonSynced] public int Communication_SyncedBuffer_06;
    [UdonSynced] public int Communication_SyncedBuffer_07;
    [UdonSynced] public int Communication_SyncedBuffer_08;
    [UdonSynced] public int Communication_SyncedBuffer_09;
    [UdonSynced] public int Communication_SyncedBuffer_10;
    [UdonSynced] public int Communication_SyncedBuffer_11;
    [UdonSynced] public int Communication_SyncedBuffer_12;
    [UdonSynced] public int Communication_SyncedBuffer_13;
    [UdonSynced] public int Communication_SyncedBuffer_14;
    [UdonSynced] public int Communication_SyncedBuffer_15;

    public int Communication_SyncedState_00;
    public int Communication_SyncedState_01;
    public int Communication_SyncedState_02;
    public int Communication_SyncedState_03;
    public int Communication_SyncedState_04;
    public int Communication_SyncedState_05;
    public int Communication_SyncedState_06;
    public int Communication_SyncedState_07;
    public int Communication_SyncedState_08;
    public int Communication_SyncedState_09;
    public int Communication_SyncedState_10;
    public int Communication_SyncedState_11;
    public int Communication_SyncedState_12;
    public int Communication_SyncedState_13;
    public int Communication_SyncedState_14;
    public int Communication_SyncedState_15;

    public string Communication_SyncedString;

    // Communication Module: Local cached values.
    private int Communication_CachedBuffer_00;
    private int Communication_CachedBuffer_01;
    private int Communication_CachedBuffer_02;
    private int Communication_CachedBuffer_03;
    private int Communication_CachedBuffer_04;
    private int Communication_CachedBuffer_05;
    private int Communication_CachedBuffer_06;
    private int Communication_CachedBuffer_07;
    private int Communication_CachedBuffer_08;
    private int Communication_CachedBuffer_09;
    private int Communication_CachedBuffer_10;
    private int Communication_CachedBuffer_11;
    private int Communication_CachedBuffer_12;
    private int Communication_CachedBuffer_13;
    private int Communication_CachedBuffer_14;
    private int Communication_CachedBuffer_15;

    private int Communication_CachedState_00;
    private int Communication_CachedState_01;
    private int Communication_CachedState_02;
    private int Communication_CachedState_03;
    private int Communication_CachedState_04;
    private int Communication_CachedState_05;
    private int Communication_CachedState_06;
    private int Communication_CachedState_07;
    private int Communication_CachedState_08;
    private int Communication_CachedState_09;
    private int Communication_CachedState_10;
    private int Communication_CachedState_11;
    private int Communication_CachedState_12;
    private int Communication_CachedState_13;
    private int Communication_CachedState_14;
    private int Communication_CachedState_15;

    public string Communication_CachedString;

    // COMMUNICATION: TEST FUNCTIONS /////////////////////////////////////////
    // Play a test sound effect.
    private void Communication_PlayTestSound()
    {
        AudioSource audioSource = ((AudioSource)GetComponent(typeof(AudioSource)));
        audioSource.Play();
    }
    private void Communication_SetTestNumber(int number)
    {
        gameRenderMaterial.SetInt("_TestNumber", number);
    }
    private void Communication_SetTestNumber2(int number)
    {
        gameRenderMaterial.SetInt("_TestNumber2", number);
    }
    private void Communication_SetTestNumber3(int number)
    {
        gameRenderMaterial.SetInt("_TestNumber3", number);
    }
    private void Communication_SetDebugString(string text)
    {
        debugText.text = text;
    }
    private void Communication_SetDebugString2(string text)
    {
        debugText2.text = text;
    }

    // Returns a string formatted view of the current contents of the queue.
    private string Communication_GetQueueValuesAsString()
    {
        string s = "";

        // For each slot in the queue, print the slot index, and the value in the slot.
        for (int i = 0; i < Communication_PeerInputCommandQueueLength; i++)
        {
            s += "(";
            s += i;
            s += ", ";
            s += Communication_PeerInputCommandQueue[i];
            s += ")\n";
        }

        return s;
    }
    // Returns a string formatted view of the current actual contents of the queue.
    private string Communication_GetActualQueueValuesAsString()
    {
        string s = "";

        // For each slot in the queue, print the slot index, and the value in the slot.
        if (Communication_PeerInputCommandQueueHead == Communication_PeerInputCommandQueueTail)
        {
            return s;
        }

        // If the queue wraps around...
        if (Communication_PeerInputCommandQueueHead > Communication_PeerInputCommandQueueTail)
        {
            // Print ending portion.
            for (int i = Communication_PeerInputCommandQueueHead + 1; i < Communication_PeerInputCommandQueueLength; i++)
            {
                var frame = (Communication_PeerInputCommandQueue[i] >> 6);
                var input = (Communication_PeerInputCommandQueue[i] & 0b111111);
                s += "(";
                s += i;
                s += ", ";
                s += frame;
                s += ", ";
                s += input;
                s += ")\n";
            }
            // Print starting portion.
            for (int i = 0; i < Communication_PeerInputCommandQueueTail; i++)
            {
                var frame = (Communication_PeerInputCommandQueue[i] >> 6);
                var input = (Communication_PeerInputCommandQueue[i] & 0b111111);
                s += "(";
                s += i;
                s += ", ";
                s += frame;
                s += ", ";
                s += input;
                s += ")\n";
            }
        }
        else
        {
            for (int i = Communication_PeerInputCommandQueueHead; i < Communication_PeerInputCommandQueueTail; i++)
            {
                var frame = (Communication_PeerInputCommandQueue[i] >> 6);
                var input = (Communication_PeerInputCommandQueue[i] & 0b111111);
                s += "(";
                s += i;
                s += ", ";
                s += frame;
                s += ", ";
                s += input;
                s += ")\n";
            }
        }

        return s;
    }

    // COMMUNICATION: LOG WRITING ////////////////////////////////////////////
    private void Communication_CommandResponse(int channel, int number, int value, int responseString)
    {
        string s = "Communication_CommandResponse: ";
        s += "(" + channel + ", " + number + ", " + value + ") ";
        s += responseString;
        Debug.Log(s);
    }

    // COMMUNICATION: METHODS ////////////////////////////////////////////////
    // Communication Module: Reset buffer index. Only when master.
    private void Communication_ResetBufferIndex()
    {
        if (Communication_CurrentState == COMMUNICATION_STATE_MASTER)
        {
            Communication_CurrentBufferIndex = 0;
            Communication_CurrentStateIndex = 0;
        }
        else
        {
            Debug.Log("Communication_ResetBufferIndex: Attempted to reset buffer index when not COMMUNICATION_STATE_MASTER.");
        }
    }

    // Returns a frame number between 0-65535
    private int Communication_GetFrameNumber()
    {
        return (Networking.GetServerTimeInMilliseconds() / 16) & 0xffff;
    }

    // Communication Module: Clear the cache.
    private void Communication_ClearCache()
    {
        Communication_CachedBuffer_00 = 0;
        Communication_CachedBuffer_01 = 0;
        Communication_CachedBuffer_02 = 0;
        Communication_CachedBuffer_03 = 0;
        Communication_CachedBuffer_04 = 0;
        Communication_CachedBuffer_05 = 0;
        Communication_CachedBuffer_06 = 0;
        Communication_CachedBuffer_07 = 0;
        Communication_CachedBuffer_08 = 0;
        Communication_CachedBuffer_09 = 0;
        Communication_CachedBuffer_10 = 0;
        Communication_CachedBuffer_11 = 0;
        Communication_CachedBuffer_12 = 0;
        Communication_CachedBuffer_13 = 0;
        Communication_CachedBuffer_14 = 0;
        Communication_CachedBuffer_15 = 0;

        Communication_CachedState_00 = 0;
        Communication_CachedState_01 = 0;
        Communication_CachedState_02 = 0;
        Communication_CachedState_03 = 0;
        Communication_CachedState_04 = 0;
        Communication_CachedState_05 = 0;
        Communication_CachedState_06 = 0;
        Communication_CachedState_07 = 0;
        Communication_CachedState_08 = 0;
        Communication_CachedState_09 = 0;
        Communication_CachedState_10 = 0;
        Communication_CachedState_11 = 0;
        Communication_CachedState_12 = 0;
        Communication_CachedState_13 = 0;
        Communication_CachedState_14 = 0;
        Communication_CachedState_15 = 0;

        Communication_CachedString = "";
    }

    // Communication Module: Write a value. Only works if Owner.
    private void Communication_WriteString(string val)
    {
        if (Communication_CurrentState == COMMUNICATION_STATE_MASTER)
        {
            Communication_CachedString = val;
        }
        else
        {
            Debug.Log("Communication_WriteString: Attempted to write string when not COMMUNICATION_STATE_MASTER.");
        }
    }

    // Communication Module: Write a string. Only works if Owner.
    private void Communication_WriteValue(int value)
    {
        if (Communication_CurrentState == COMMUNICATION_STATE_MASTER)
        {
            if (Communication_CurrentBufferIndex == 0) Communication_CachedBuffer_00 = value;
            if (Communication_CurrentBufferIndex == 1) Communication_CachedBuffer_01 = value;
            if (Communication_CurrentBufferIndex == 2) Communication_CachedBuffer_02 = value;
            if (Communication_CurrentBufferIndex == 3) Communication_CachedBuffer_03 = value;
            if (Communication_CurrentBufferIndex == 4) Communication_CachedBuffer_04 = value;
            if (Communication_CurrentBufferIndex == 5) Communication_CachedBuffer_05 = value;
            if (Communication_CurrentBufferIndex == 6) Communication_CachedBuffer_06 = value;
            if (Communication_CurrentBufferIndex == 7) Communication_CachedBuffer_07 = value;
            if (Communication_CurrentBufferIndex == 8) Communication_CachedBuffer_08 = value;
            if (Communication_CurrentBufferIndex == 9) Communication_CachedBuffer_09 = value;
            if (Communication_CurrentBufferIndex == 10) Communication_CachedBuffer_10 = value;
            if (Communication_CurrentBufferIndex == 11) Communication_CachedBuffer_11 = value;
            if (Communication_CurrentBufferIndex == 12) Communication_CachedBuffer_12 = value;
            if (Communication_CurrentBufferIndex == 13) Communication_CachedBuffer_13 = value;
            if (Communication_CurrentBufferIndex == 14) Communication_CachedBuffer_14 = value;
            if (Communication_CurrentBufferIndex == 15) Communication_CachedBuffer_15 = value;

            Communication_CurrentBufferIndex++;
            if (Communication_CurrentBufferIndex > 15)
            {
                Communication_CurrentBufferIndex = 0;
            }
        }
        else
        {
            Debug.Log("Communication_WriteValue: Attempted to write value when not COMMUNICATION_STATE_MASTER.");
        }
    }

    private void Communication_WriteStateValue(int value)
    {
        if (Communication_CurrentState == COMMUNICATION_STATE_MASTER)
        {
            if (Communication_CurrentStateIndex == 0) Communication_CachedBuffer_00 = value;
            if (Communication_CurrentStateIndex == 1) Communication_CachedBuffer_01 = value;
            if (Communication_CurrentStateIndex == 2) Communication_CachedBuffer_02 = value;
            if (Communication_CurrentStateIndex == 3) Communication_CachedBuffer_03 = value;
            if (Communication_CurrentStateIndex == 4) Communication_CachedBuffer_04 = value;
            if (Communication_CurrentStateIndex == 5) Communication_CachedBuffer_05 = value;
            if (Communication_CurrentStateIndex == 6) Communication_CachedBuffer_06 = value;
            if (Communication_CurrentStateIndex == 7) Communication_CachedBuffer_07 = value;
            if (Communication_CurrentStateIndex == 8) Communication_CachedBuffer_08 = value;
            if (Communication_CurrentStateIndex == 9) Communication_CachedBuffer_09 = value;
            if (Communication_CurrentStateIndex == 10) Communication_CachedBuffer_10 = value;
            if (Communication_CurrentStateIndex == 11) Communication_CachedBuffer_11 = value;
            if (Communication_CurrentStateIndex == 12) Communication_CachedBuffer_12 = value;
            if (Communication_CurrentStateIndex == 13) Communication_CachedBuffer_13 = value;
            if (Communication_CurrentStateIndex == 14) Communication_CachedBuffer_14 = value;
            if (Communication_CurrentStateIndex == 15) Communication_CachedBuffer_15 = value;

            Communication_CurrentStateIndex++;
            if (Communication_CurrentStateIndex > 15)
            {
                Communication_CurrentStateIndex = 0;
            }
        }
        else
        {
            Debug.Log("Communication_WriteValue: Attempted to write value when not COMMUNICATION_STATE_MASTER.");
        }
    }

    // COMMUNICATION: DATA STRUCTURES ////////////////////////////////////////
    // Initialize the command queue
    // Returns true if the queue is empty.
    private bool Communication_PeerInputCommandQueue_IsEmpty()
    {
        return Communication_PeerInputCommandQueueHead == Communication_PeerInputCommandQueueTail;
    }

    // Returns the last value of the queue.
    private int Communication_PeerInputCommandQueue_GetTailValue()
    {
        return Communication_PeerInputCommandQueue[Communication_PeerInputCommandQueueTail];
    }

    // Appends a value to the queue.
    private void Communication_PeerInputCommandQueue_AppendValue(int value)
    {
        // Move the tail forward, wrapping if necessary
        Communication_PeerInputCommandQueueTail++;
        if (Communication_PeerInputCommandQueueTail >= Communication_PeerInputCommandQueueLength)
        {
            Communication_PeerInputCommandQueueTail = 0;
        }

        // Set the tail value.
        Communication_PeerInputCommandQueue[Communication_PeerInputCommandQueueTail] = value;
    }

    // Returns the frontmost value of the queue and advances the queue.
    private int Communication_PeerInputCommandQueue_ConsumeValue()
    {
        // Move the head forward, wrapping if necessary.
        Communication_PeerInputCommandQueueHead++;
        if (Communication_PeerInputCommandQueueHead >= Communication_PeerInputCommandQueueLength)
        {
            Communication_PeerInputCommandQueueHead = 0;
        }

        // Return the head value.
        return Communication_PeerInputCommandQueue[Communication_PeerInputCommandQueueHead];
    }

    // Returns the frontmost value of the queue without advancing the queue.
    private int Communication_PeerInputCommandQueue_PeekValue()
    {
        // Return the head value.
        int aheadValue = Communication_PeerInputCommandQueueHead + 1;
        if (aheadValue >= Communication_PeerInputCommandQueueLength)
        {
            aheadValue = 0;
        }
        return Communication_PeerInputCommandQueue[aheadValue];
    }

    // Empties the queue.
    private void Communication_ResetPeerInputCommandQueue()
    {
        Communication_PeerInputCommandQueueHead = 0;
        Communication_PeerInputCommandQueueTail = 0;
    }

    // COMMUNICATION: STATE-SPECIFIC HANDLERS ////////////////////////////////
    // STATE TRANSITIONS
    private void Communication_EnterState_Uninitialized()
    {
        // Do nothing.
    }

    private void Communication_EnterState_Master()
    {
        Communication_ClearCache();
        Communication_ResetBufferIndex();
    }

    private void Communication_EnterState_Peer()
    {
        Communication_ClearCache();
        Communication_ResetPeerInputCommandQueue();
        Communication_PeerAdditonalDelay = 0;
    }

    // DESERIALIZATION
    private int Communication_OnDeserialization_Peer_GetSmallerValidFrame(int a, int b)
    {
        // Check if the frame is valid: If the frame number is larger than the queue tail, we can use this.
        // We can't use it if it's smaller because a smaller value would have already been added at this point.
        int frameNumberA = (a >> 6);
        int frameNumberB = (b >> 6);
        int frameNumberTail = (Communication_PeerInputCommandQueue_GetTailValue() >> 6);

        // Check validity:
        // - TRUE if the queue is empty (huh?) //Communication_PeerInputCommandQueue_IsEmpty()
        // - TRUE if the value is larger than the head of the queue
        // - FALSE otherwise.
        if (frameNumberA > frameNumberTail)
        {
            // Return the smaller frame.
            return (frameNumberA < frameNumberB) ? a : b;

        }
        return b;
    }
    private void Communication_OnDeserialization_Peer_GetNextValue()
    {
        // Get the smallest value, add it to the queue if it is valid.
        int smallestFrame = 2147000000;
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_00, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_01, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_02, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_03, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_04, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_05, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_06, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_07, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_08, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_09, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_10, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_11, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_12, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_13, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_14, smallestFrame);
        smallestFrame = Communication_OnDeserialization_Peer_GetSmallerValidFrame(Communication_CachedBuffer_15, smallestFrame);

        // If we got a valid frame, add it to the end of the queue.
        if (smallestFrame != 2147000000)
        {
            Communication_PeerInputCommandQueue_AppendValue(smallestFrame);
            Communication_PlayTestSound();

            // Display the number that was found.
            string s = "";
            s += smallestFrame;
            s += ", ";
            s += Communication_CurrentFrameNumber;
            Communication_SetDebugString2(s);
        }
    }

    private void Communication_OnDeserialization_Peer()
    {
        // Copy all the values to the cache.
        if (Communication_SyncedBuffer_00 != Communication_CachedBuffer_00) Communication_CachedBuffer_00 = Communication_SyncedBuffer_00;
        if (Communication_SyncedBuffer_01 != Communication_CachedBuffer_01) Communication_CachedBuffer_01 = Communication_SyncedBuffer_01;
        if (Communication_SyncedBuffer_02 != Communication_CachedBuffer_02) Communication_CachedBuffer_02 = Communication_SyncedBuffer_02;
        if (Communication_SyncedBuffer_03 != Communication_CachedBuffer_03) Communication_CachedBuffer_03 = Communication_SyncedBuffer_03;
        if (Communication_SyncedBuffer_04 != Communication_CachedBuffer_04) Communication_CachedBuffer_04 = Communication_SyncedBuffer_04;
        if (Communication_SyncedBuffer_05 != Communication_CachedBuffer_05) Communication_CachedBuffer_05 = Communication_SyncedBuffer_05;
        if (Communication_SyncedBuffer_06 != Communication_CachedBuffer_06) Communication_CachedBuffer_06 = Communication_SyncedBuffer_06;
        if (Communication_SyncedBuffer_07 != Communication_CachedBuffer_07) Communication_CachedBuffer_07 = Communication_SyncedBuffer_07;
        if (Communication_SyncedBuffer_08 != Communication_CachedBuffer_08) Communication_CachedBuffer_08 = Communication_SyncedBuffer_08;
        if (Communication_SyncedBuffer_09 != Communication_CachedBuffer_09) Communication_CachedBuffer_09 = Communication_SyncedBuffer_09;
        if (Communication_SyncedBuffer_10 != Communication_CachedBuffer_10) Communication_CachedBuffer_10 = Communication_SyncedBuffer_10;
        if (Communication_SyncedBuffer_11 != Communication_CachedBuffer_11) Communication_CachedBuffer_11 = Communication_SyncedBuffer_11;
        if (Communication_SyncedBuffer_12 != Communication_CachedBuffer_12) Communication_CachedBuffer_12 = Communication_SyncedBuffer_12;
        if (Communication_SyncedBuffer_13 != Communication_CachedBuffer_13) Communication_CachedBuffer_13 = Communication_SyncedBuffer_13;
        if (Communication_SyncedBuffer_14 != Communication_CachedBuffer_14) Communication_CachedBuffer_14 = Communication_SyncedBuffer_14;
        if (Communication_SyncedBuffer_15 != Communication_CachedBuffer_15) Communication_CachedBuffer_15 = Communication_SyncedBuffer_15;

        // When Peer receives a string, base64decode it and display it.
        if (Communication_SyncedString != Communication_CachedString)
        {
            System.Convert.FromBase64String(Communication_SyncedString);
        }

        // Read the values and put them into the input command queue.
        // Try to do this 16 times. Hahahaha!!!
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();
        Communication_OnDeserialization_Peer_GetNextValue();

        // If the queue is empty, we can't simulate anything. But if the queue has data, we can.
    }

    // PRE-SERIALIZATION
    private void Communication_OnPreSerialization_Master()
    {
        // Copy changed values from cache to synced variables.
        if (Communication_SyncedBuffer_00 != Communication_CachedBuffer_00) Communication_SyncedBuffer_00 = Communication_CachedBuffer_00;
        if (Communication_SyncedBuffer_01 != Communication_CachedBuffer_01) Communication_SyncedBuffer_01 = Communication_CachedBuffer_01;
        if (Communication_SyncedBuffer_02 != Communication_CachedBuffer_02) Communication_SyncedBuffer_02 = Communication_CachedBuffer_02;
        if (Communication_SyncedBuffer_03 != Communication_CachedBuffer_03) Communication_SyncedBuffer_03 = Communication_CachedBuffer_03;
        if (Communication_SyncedBuffer_04 != Communication_CachedBuffer_04) Communication_SyncedBuffer_04 = Communication_CachedBuffer_04;
        if (Communication_SyncedBuffer_05 != Communication_CachedBuffer_05) Communication_SyncedBuffer_05 = Communication_CachedBuffer_05;
        if (Communication_SyncedBuffer_06 != Communication_CachedBuffer_06) Communication_SyncedBuffer_06 = Communication_CachedBuffer_06;
        if (Communication_SyncedBuffer_07 != Communication_CachedBuffer_07) Communication_SyncedBuffer_07 = Communication_CachedBuffer_07;
        if (Communication_SyncedBuffer_08 != Communication_CachedBuffer_08) Communication_SyncedBuffer_08 = Communication_CachedBuffer_08;
        if (Communication_SyncedBuffer_09 != Communication_CachedBuffer_09) Communication_SyncedBuffer_09 = Communication_CachedBuffer_09;
        if (Communication_SyncedBuffer_10 != Communication_CachedBuffer_10) Communication_SyncedBuffer_10 = Communication_CachedBuffer_10;
        if (Communication_SyncedBuffer_11 != Communication_CachedBuffer_11) Communication_SyncedBuffer_11 = Communication_CachedBuffer_11;
        if (Communication_SyncedBuffer_12 != Communication_CachedBuffer_12) Communication_SyncedBuffer_12 = Communication_CachedBuffer_12;
        if (Communication_SyncedBuffer_13 != Communication_CachedBuffer_13) Communication_SyncedBuffer_13 = Communication_CachedBuffer_13;
        if (Communication_SyncedBuffer_14 != Communication_CachedBuffer_14) Communication_SyncedBuffer_14 = Communication_CachedBuffer_14;
        if (Communication_SyncedBuffer_15 != Communication_CachedBuffer_15) Communication_SyncedBuffer_15 = Communication_CachedBuffer_15;

        // Copy changed values from cache to synced variables.
        if (Communication_SyncedState_00 != Communication_CachedState_00) Communication_SyncedState_00 = Communication_CachedState_00;
        if (Communication_SyncedState_01 != Communication_CachedState_01) Communication_SyncedState_01 = Communication_CachedState_01;
        if (Communication_SyncedState_02 != Communication_CachedState_02) Communication_SyncedState_02 = Communication_CachedState_02;
        if (Communication_SyncedState_03 != Communication_CachedState_03) Communication_SyncedState_03 = Communication_CachedState_03;
        if (Communication_SyncedState_04 != Communication_CachedState_04) Communication_SyncedState_04 = Communication_CachedState_04;
        if (Communication_SyncedState_05 != Communication_CachedState_05) Communication_SyncedState_05 = Communication_CachedState_05;
        if (Communication_SyncedState_06 != Communication_CachedState_06) Communication_SyncedState_06 = Communication_CachedState_06;
        if (Communication_SyncedState_07 != Communication_CachedState_07) Communication_SyncedState_07 = Communication_CachedState_07;
        if (Communication_SyncedState_08 != Communication_CachedState_08) Communication_SyncedState_08 = Communication_CachedState_08;
        if (Communication_SyncedState_09 != Communication_CachedState_09) Communication_SyncedState_09 = Communication_CachedState_09;
        if (Communication_SyncedState_10 != Communication_CachedState_10) Communication_SyncedState_10 = Communication_CachedState_10;
        if (Communication_SyncedState_11 != Communication_CachedState_11) Communication_SyncedState_11 = Communication_CachedState_11;
        if (Communication_SyncedState_12 != Communication_CachedState_12) Communication_SyncedState_12 = Communication_CachedState_12;
        if (Communication_SyncedState_13 != Communication_CachedState_13) Communication_SyncedState_13 = Communication_CachedState_13;
        if (Communication_SyncedState_14 != Communication_CachedState_14) Communication_SyncedState_14 = Communication_CachedState_14;
        if (Communication_SyncedState_15 != Communication_CachedState_15) Communication_SyncedState_15 = Communication_CachedState_15;

        if (Communication_CachedString != Communication_SyncedString) Communication_SyncedString = Communication_CachedString;
    }

    // UPDATE
    void Communication_Update_Master()
    {
        //Debug.Log("[FC] Communication_Update_Master");

        // In the Master, CurrentFrameNumber is used for stamping the frame and advancing the simulation.

        int newFrameNumber = Communication_GetFrameNumber();
        Communication_SetTestNumber2(newFrameNumber);
        if (newFrameNumber > Communication_CurrentFrameNumber)
        {
            Communication_SetTestNumber3(newFrameNumber);
            //Debug.Log("[FC] Communication_Update_Master: Next frame");

            Communication_CurrentFrameNumber = newFrameNumber;

            // We are the owner, we always have data to give it.
            // Set the input buffer to the current controller state.
            int inputState = Communication_GetInputState();

            Communication_MasterHeartBeat++;
            if (inputState != Communication_PreviousInputState || Communication_MasterHeartBeat > 20)
            {
                Communication_MasterHeartBeat = 0;
                gameLogicMaterial.SetInt("_PlayerOneJoystick", inputState);
                Communication_SetTestNumber(inputState);
                Communication_PreviousInputState = inputState;
                //Debug.Log(inputState);
                //Communication_PlayTestSound();

                int stampedInputState = (newFrameNumber << 6) | inputState;
                string s = "";
                s += stampedInputState;
                Communication_SetDebugString2(s);

                // Send the input state over the network.
                Communication_WriteValue(stampedInputState);
            }

            // Perform a clock tick.
            Communication_DoClockTick();
        }
    }

    void Communication_Update_Peer_FrameAdvance()
    {
        Debug.Log("[FC] Communication_Update_Peer: Next frame for reals");
        Communication_DoClockTick();
        Communication_PlayTestSound();
        Communication_SetTestNumber2(Communication_CurrentFrameNumber);

        // Only change the input if we have reached the correct frame to do so.
        int nextCommandFrameNumber = (Communication_PeerInputCommandQueue_PeekValue() >> 6);
        int delayedNextCommandFrameNumber = Communication_PeerAdditonalDelay + nextCommandFrameNumber;

        // TODO: HANDLE DESYNC CONDITION
        if (Communication_CurrentFrameNumber > delayedNextCommandFrameNumber)
        {
            Communication_PeerAdditonalDelay = (Communication_CurrentFrameNumber - delayedNextCommandFrameNumber);
            delayedNextCommandFrameNumber = Communication_PeerAdditonalDelay + nextCommandFrameNumber;

            var s = "APPLIED DELAY: ";
            s += Communication_PeerAdditonalDelay;
            s += "        Frame No: ";
            s += Communication_CurrentFrameNumber;
            s += ",       Next Command Frame No: ";
            s += nextCommandFrameNumber;
            Communication_SetDebugString2(s);

            // TODO: Resync logic. For now we cheat and just set the frame number to teleport ahead.
            nextCommandFrameNumber = Communication_CurrentFrameNumber;
        }

        // When we get to the correct frame...
        if (Communication_CurrentFrameNumber == delayedNextCommandFrameNumber)
        {
            // Get the input to use.
            int inputState = Communication_PeerInputCommandQueue_ConsumeValue();
            gameLogicMaterial.SetInt("_PlayerOneJoystick", inputState);
            Communication_SetTestNumber3(inputState);
        }
    }

    void Communication_Update_Peer_FrameTimeElapsed()
    {
        // Only advance the simulation if we have data to give it.
        if (!Communication_PeerInputCommandQueue_IsEmpty())
        {
            Communication_Update_Peer_FrameAdvance();
        }
    }

    void Communication_Update_Peer()
    {
        Debug.Log("[FC] Communication_Update_Peer");
        Communication_SetDebugString(Communication_GetActualQueueValuesAsString());

        // In the Peer, CurrentFrameNumber is used only for advancing the simulation. It is not compared against anything.
        int newFrameNumber = Communication_GetFrameNumber();
        if (newFrameNumber > Communication_CurrentFrameNumber)
        {
            Debug.Log("[FC] Communication_Update_Peer: Next frame");
            Communication_CurrentFrameNumber = newFrameNumber;
            Communication_SetTestNumber(newFrameNumber);

            Communication_Update_Peer_FrameTimeElapsed();
        }
    }
    void Communication_DoClockTick()
    {
        gameLogicMaterial.SetInt("_ExternalClockTick", Communication_ClockTick);
        Communication_ClockTick = (Communication_ClockTick > 0) ? 0 : 65536;
    }

    // MIDINOTEON
    void Communication_MidiNoteOn_Master(int channel, int number, int velocity)
    {
        // Do a dumb log statement always.
        string s = "Communication_MidiNoteOn_Master:";
        s += channel + " " + number + " " + velocity;
        Debug.Log(s);

        // Process the command.
        switch(number)
        {
            case COMMUNICATION_MIDI_COMMAND_IDENTIFY:
                Communication_MidiCommand_Identify(velocity);
                break;
            case COMMUNICATION_MIDI_COMMAND_PING:
                Communication_MidiCommand_Ping(velocity);
                break;
        }
    }

    void Communication_MidiNoteOn_Peer(int channel, int number, int velocity)
    {
        // Do a dumb log statement always.
        string s = "Communication_MidiNoteOn_Peer:";
        s += channel + " " + number + " " + velocity;
        Debug.Log(s);

        // Process the command.
        switch (number)
        {
            case COMMUNICATION_MIDI_COMMAND_IDENTIFY:
                Communication_MidiCommand_Identify(velocity);
                break;
            case COMMUNICATION_MIDI_COMMAND_PING:
                Communication_MidiCommand_Ping(velocity);
                break;
        }
    }

    // MIDINOTEOFF
    //void Communication_MidiNoteOff_Master(int channel, int number, int velocity)
    //{
    //    string s = "Communication_MidiNoteOff_Master:";
    //    s += channel + " " + number + " " + velocity;
    //    Debug.Log(s);
    //}

    //void Communication_MidiNoteOff_Peer(int channel, int number, int velocity)
    //{
    //    string s = "Communication_MidiNoteOff_Peer:";
    //    s += channel + " " + number + " " + velocity;
    //    Debug.Log(s);
    //}

    // MIDICONTROLCHANGE
    //void Communication_MidiControlChange_Master(int channel, int number, int value)
    //{
    //    string s = "Communication_MidiControlChange_Master:";
    //    s += channel + " " + number + " " + value;
    //    Debug.Log(s);
    //}

    //void Communication_MidiControlChange_Peer(int channel, int number, int value)
    //{
    //    string s = "Communication_MidiControlChange_Peer:";
    //    s += channel + " " + number + " " + value;
    //    Debug.Log(s);
    //}

    // COMMUNICTION: MIDI IN /////////////////////////////////////////////////

    // The IDENTIFY command is how we associate a VRC instance's logfile with a MIDI session.
    // The command sender app will first send IDENTIFY and then scrape the logfile for the returned value.
    // vrchat.exe's role in this procedure is to emit a line in the logfile.
    private void Communication_MidiCommand_Identify(int value)
    {
        string s = "Communication_Identify ";
        s += value;
        Debug.Log(s);
    }

    // The PING command does nothing in particular to affect the state of vrchat.exe.
    // It simply writes PONG to the log.
    private void Communication_MidiCommand_Ping(int value)
    {
        string s = "Communication_Ping ";
        s += "PONG";
        Debug.Log(s);
    }

    // COMMUNICATION: IO /////////////////////////////////////////////////////
    private int Communication_PackInputState(float vx, float vy, bool b, bool a)
    {
        int state = 0;

        if (a) state |= 1;
        if (b) state |= 2;
        if (vx < 0) state |= 4;
        if (vx > 0) state |= 8;
        if (vy < 0) state |= 16;
        if (vy > 0) state |= 32;

        return state;
    }
    private int Communication_GetInputState()
    {
        var triggerDeadzone = .3;
        var stickDeadzone = .3;

        var b_button = Input.GetAxis("Oculus_CrossPlatform_SecondaryIndexTrigger") > triggerDeadzone;
        var a_button = Input.GetButton("Fire2") || Input.GetButton("Cancel");

        b_button |= Input.GetKey("x") || Input.GetKey("j");
        a_button |= Input.GetKey("c") || Input.GetKey("k");

        float vx = Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickHorizontal");
        float vy = -Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickVertical");

        if (Input.GetKey("up") || Input.GetKey("w") || Input.GetKey("z"))
        {
            vy = -1;
        }
        else if (Input.GetKey("down") || Input.GetKey("s"))
        {
            vy = 1;
        }

        if (Input.GetKey("left") || Input.GetKey("a") || Input.GetKey("q"))
        {
            vx = -1;
        }
        else if (Input.GetKey("right") || Input.GetKey("d"))
        {
            vx = 1;
        }
        if (Mathf.Abs(vx) < stickDeadzone)
        {
            vx = 0;
        }
        if (Mathf.Abs(vy) < stickDeadzone)
        {
            vy = 0;
        }

        return Communication_PackInputState(vx, vy, b_button, a_button);
    }

    // COMMUNICATION: EVENT HANDLERS /////////////////////////////////////////
    private void Communication_ChangeState(int newState)
    {
        Communication_CurrentState = newState;

        switch (newState)
        {
            case COMMUNICATION_STATE_UNINITIALIZED:
                Communication_EnterState_Uninitialized();
                break;
            case COMMUNICATION_STATE_MASTER:
                Communication_EnterState_Master();
                break;
            case COMMUNICATION_STATE_PEER:
                Communication_EnterState_Peer();
                break;
        }
    }

    private void Communication_Start()
    {
        // There's some potential race conditions to consider around states and OnDeserialization events
        Communication_ChangeState(COMMUNICATION_STATE_UNINITIALIZED);

        // Enter the correct state depending on whether master or peer.
        if (Networking.IsMaster)
        {
            Communication_ChangeState(COMMUNICATION_STATE_MASTER);
        }
        else
        {
            Communication_ChangeState(COMMUNICATION_STATE_PEER);
        }
    }

    private void Communication_OnPreSerialization()
    {
        switch (Communication_CurrentState)
        {
            case COMMUNICATION_STATE_UNINITIALIZED:
                break;
            case COMMUNICATION_STATE_MASTER:
                Communication_OnPreSerialization_Master();
                break;
            case COMMUNICATION_STATE_PEER:
                break;
        }
    }

    private void Communication_OnDeserialization()
    {
        switch (Communication_CurrentState)
        {
            case COMMUNICATION_STATE_UNINITIALIZED:
                break;
            case COMMUNICATION_STATE_MASTER:
                break;
            case COMMUNICATION_STATE_PEER:
                Communication_OnDeserialization_Peer();
                break;
        }
    }

    private void Communication_Interact()
    {
        switch (Communication_CurrentState)
        {
            case COMMUNICATION_STATE_UNINITIALIZED:
                break;
            case COMMUNICATION_STATE_MASTER:
                Communication_WriteValue(Networking.GetServerTimeInMilliseconds());
                break;
            case COMMUNICATION_STATE_PEER:
                break;
        }
    }

    private void Communication_Update()
    {
        switch (Communication_CurrentState)
        {
            case COMMUNICATION_STATE_UNINITIALIZED:
                break;
            case COMMUNICATION_STATE_MASTER:
                Communication_Update_Master();
                break;
            case COMMUNICATION_STATE_PEER:
                Communication_Update_Peer();
                break;
        }
    }

    private void Communication_MidiNoteOn(int channel, int number, int velocity)
    {
        switch (Communication_CurrentState)
        {
            case COMMUNICATION_STATE_UNINITIALIZED:
                break;
            case COMMUNICATION_STATE_MASTER:
                Communication_MidiNoteOn_Master(channel, number, velocity);
                break;
            case COMMUNICATION_STATE_PEER:
                Communication_MidiNoteOn_Peer(channel, number, velocity);
                break;
        }
    }

    //private void Communication_MidiNoteOff(int channel, int number, int velocity)
    //{
    //    switch (Communication_CurrentState)
    //    {
    //        case COMMUNICATION_STATE_UNINITIALIZED:
    //            break;
    //        case COMMUNICATION_STATE_MASTER:
    //            Communication_MidiNoteOff_Master(channel, number, velocity);
    //            break;
    //        case COMMUNICATION_STATE_PEER:
    //            Communication_MidiNoteOff_Peer(channel, number, velocity);
    //            break;
    //    }
    //}

    //private void Communication_MidiControlChange(int channel, int number, int value)
    //{
    //    switch (Communication_CurrentState)
    //    {
    //        case COMMUNICATION_STATE_UNINITIALIZED:
    //            break;
    //        case COMMUNICATION_STATE_MASTER:
    //            Communication_MidiControlChange_Master(channel, number, value);
    //            break;
    //        case COMMUNICATION_STATE_PEER:
    //            Communication_MidiControlChange_Peer(channel, number, value);
    //            break;
    //    }
    //}

    // GAME OBJECT ///////////////////////////////////////////////////////////
    private void Start()
    {
        Debug.Log("[FC] Start");
        Communication_Start();
    }

    public override void OnPreSerialization()
    {
        Debug.Log("[FC] OnPreSerialization");
        Communication_OnPreSerialization();
    }

    public override void OnDeserialization()
    {
        Debug.Log("[FC] OnDeserialization");
        Communication_OnDeserialization();
    }

    public override void Interact()
    {
        Debug.Log("[FC] Interact");
        Communication_Interact();
    }

    private void Update()
    {
        //Debug.Log("[FC] Update");
        Communication_Update();
    }

    public override void MidiNoteOn(int channel, int number, int velocity)
    {
        Communication_MidiNoteOn(channel, number, velocity);
    }

    //public override void MidiNoteOff(int channel, int number, int velocity)
    //{
    //    Communication_MidiNoteOff(channel, number, velocity);
    //}

    //public override void MidiControlChange(int channel, int number, int value)
    //{
    //    Communication_MidiControlChange(channel, number, value);
    //}
}

