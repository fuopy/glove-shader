
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class s_plane_superb2_logic : UdonSharpBehaviour
{
    public Material gameLogicMaterial;

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

    private void OnPostRender()
    {
        Texture2D tex = (Texture2D)gameLogicMaterial.GetTexture("LogicCanvas");
        tex.ReadPixels(new Rect(0, 0, 1, 1), 0, 0, false);
        Color[] pixels = tex.GetPixels();
        Debug.Log(pixels.GetValue(1));
        // TODO: read only the relevant game data.
    }

    private void Update()
    {
        var inputState = Communication_GetInputState();
        gameLogicMaterial.SetInt("_PlayerOneJoystick", inputState);


        //var triggerDeadzone = .3;
        //var stickDeadzone = .3;

        //var b_button = Input.GetAxis("Oculus_CrossPlatform_SecondaryIndexTrigger") > triggerDeadzone;
        //var a_button = Input.GetButton("Fire2") || Input.GetButton("Cancel");

        //b_button |= Input.GetKey("x") || Input.GetKey("j");
        //a_button |= Input.GetKey("c") || Input.GetKey("k");

        //float vx = Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickHorizontal");
        //float vy = -Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickVertical");

        //if (Input.GetKey("up") || Input.GetKey("w") || Input.GetKey("z"))
        //{
        //    vy = -1;
        //}
        //else if (Input.GetKey("down") || Input.GetKey("s"))
        //{
        //    vy = 1;
        //}

        //if (Input.GetKey("left") || Input.GetKey("a") || Input.GetKey("q"))
        //{
        //    vx = -1;
        //}
        //else if (Input.GetKey("right") || Input.GetKey("d"))
        //{
        //    vx = 1;
        //}

        //if (Mathf.Abs(vx) < stickDeadzone)
        //{
        //    vx = 0;
        //}
        //if (Mathf.Abs(vy) < stickDeadzone)
        //{
        //    vy = 0;
        //}

        //Vector4 playerOneJoystick = new Vector4(vx, vy, b_button ? 1 : 0, a_button ? 1 : 0);

        //renderMaterial.SetVector("_PlayerOneJoystick", playerOneJoystick);
    }
}
