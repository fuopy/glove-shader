
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class s_plane_superb_renderer : UdonSharpBehaviour
{
    public override void Interact()
    {
        // Have player sit in chair.
        var station = ((VRCStation)GetComponent(typeof(VRCStation)));
        station.UseStation(Networking.LocalPlayer);
    }
}
