
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class s_camera : UdonSharpBehaviour
{
    [SerializeField]
    private Texture2D texture;

    public GameObject sfxAccept;
    public GameObject sfxBack;
    public GameObject sfxCup;
    public GameObject sfxEnemyDefeat;
    public GameObject sfxGold;
    public GameObject sfxKey;
    public GameObject sfxLemon;
    public GameObject sfxMove;
    public GameObject sfxPoo;
    public GameObject sfxShoot;
    public GameObject sfxSpawnerDefeat;
    public GameObject sfxSpawnerHit;

    int stupid = 0;

    int soundArrayStart = 0; // 256 * 80;

    int soundAccept = 20;
    int soundBack = 1;
    int soundCup = 2;
    int soundEnemyDefeat = 3;
    int soundGold = 4;
    int soundKey = 5;
    int soundLemon = 6;
    int soundMove = 7;
    int soundPoo = 8;
    int soundShoot = 0;
    int soundSpawnerDefeat = 10;
    int soundSpawnerHit = 11;

    private void OnPostRender()
    {
        texture.ReadPixels(new Rect(0, 255-80, texture.width, 1), 0, 0, false);
        Color[] pixels = texture.GetPixels();
        Debug.Log(pixels[0]);

        // Accept
        if (pixels[soundArrayStart + soundAccept].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxAccept.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Back
        if (pixels[soundArrayStart + soundBack].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxBack.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Cup
        if (pixels[soundArrayStart + soundCup].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxCup.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Enemy Defeat
        if (pixels[soundArrayStart + soundEnemyDefeat].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxEnemyDefeat.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Gold
        if (pixels[soundArrayStart + soundGold].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxGold.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Key
        if (pixels[soundArrayStart + soundKey].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxKey.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Lemon
        if (pixels[soundArrayStart + soundLemon].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxLemon.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }
        // Move
        if (pixels[soundArrayStart + soundMove].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxMove.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }

        // Poo
        if (pixels[soundArrayStart + soundPoo].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxPoo.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }

        // Shoot
        if (pixels[soundArrayStart + soundShoot].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxShoot.GetComponent(typeof(AudioSource)));
            audioSource.Stop();
            audioSource.Play();
        }

        // Spawner Defeat
        if (pixels[soundArrayStart + soundSpawnerDefeat].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxSpawnerDefeat.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }

        // Spawner Hit
        if (pixels[soundArrayStart + soundSpawnerHit].r > 0.0)
        {
            var audioSource = ((AudioSource)sfxSpawnerHit.GetComponent(typeof(AudioSource)));
            audioSource.Play();
        }

        //if (pixels[0].r > 0.0)
        //{
        //    var audioSource = ((AudioSource)sfxEnemyDefeat.GetComponent(typeof(AudioSource)));
        //    audioSource.Stop();
        //    audioSource.Play();
        //}
        //var audioSource = ((AudioSource)sfxEnemyDefeat.GetComponent(typeof(AudioSource)));
        //audioSource.Stop();
        //audioSource.Play();

        //if (pixels[0].r > 0.0)
        //{
        //stupid++;
        //if (stupid > 10)
        //{
        //var audioSource = ((AudioSource)sfxEnemyDefeat.GetComponent(typeof(AudioSource)));
        //audioSource.Play();
        //stupid = 0;
        //}
        //}
    }

    private void Update()
    {
    }

    void Start()
    {
        gameObject.SetActive(true);
    }
}
