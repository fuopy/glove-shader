
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class s_camera_superb : UdonSharpBehaviour
{
    [SerializeField]
    private Texture2D texture;

    private void OnPostRender()
    {
        texture.ReadPixels(new Rect(0, 0, texture.width, texture.height), 0, 0, false);
        Color[] pixels = texture.GetPixels();
        //Debug.Log(pixels[0]);
    }
    void Start()
    {
        gameObject.SetActive(true);
    }
}



//public Material inputMaterial;
//public Material logicMaterial;


//// Read pixels from input buffer.
//Texture2D inputTex = (Texture2D)inputMaterial.GetTexture("InputBufferCanvas");
//inputTex.ReadPixels(new Rect(0, 0, 1, 1), 0, 0, false);
//Color[] inputPixels = inputTex.GetPixels();

//// Read pixels from logic buffer.
//Texture2D logicTex = (Texture2D)logicMaterial.GetTexture("GameProcessorCanvas");
//logicTex.ReadPixels(new Rect(0, 0, 1, 1), 0, 0, false);
//Color[] logicPixels = logicTex.GetPixels();

//// TODO: read only the relevant game data.
//Debug.Log(inputPixels.GetValue(0));

//// Test to see if we can read the bottom left pixel.