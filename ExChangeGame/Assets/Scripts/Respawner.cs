using System;
using System.Collections;
using UnityEngine;

[RequireComponent(typeof(AudioSource))] 
[RequireComponent(typeof(Collider))] 
public class Respawner : MonoBehaviour
{
    private static Respawner _currentRespawnPoint;
    
    [SerializeField] private bool isMainSpawnPoint;
    [SerializeField] private Vector3 spawnPoint;
    [SerializeField] DissolvePixel dissolvePixel;


    [SerializeField] private float fadeTime = 1;
    [SerializeField] private float inFadeTime = 1;
    [SerializeField] private float effectTime = 1;

        private AudioSource _audioSource;

    private WaitForSeconds _waitforFade;
    private WaitForSeconds _waitInFade;
    private WaitForSeconds _waitEffect;
    
    public static void Respawn(PlayerInstance player)
    {
        if(_currentRespawnPoint) _currentRespawnPoint.Spawn(player);
    }
    
    private void Awake()
    {
        if (isMainSpawnPoint)
        {
            _currentRespawnPoint = this;
        }
    }

    private void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        _waitforFade = new WaitForSeconds(fadeTime);
        _waitInFade = new WaitForSeconds(inFadeTime);
        _waitEffect = new WaitForSeconds(effectTime-1);
    }

    private void Spawn(PlayerInstance player)
    {
        StartCoroutine(TransferPlayer(player));
    }
    
    private IEnumerator TransferPlayer(PlayerInstance player)
    {
        var playerTransform = player.transform;
        playerTransform.GetChild(0).gameObject.SetActive(false);
        player.PlayerMovement.CanMove = false;
        Overlay.Instance.FadeIn(fadeTime);
        yield return _waitforFade;
        player.transform.position = transform.position + spawnPoint;
        yield return _waitInFade;
        Overlay.Instance.FadeOut(fadeTime);
        yield return _waitforFade;
        dissolvePixel.DissolveOut(effectTime);
        _audioSource.Play();
        yield return _waitEffect;
        dissolvePixel.DissolveIn(effectTime);
        yield return _waitEffect;
        player.PlayerMovement.CanMove = true;
        player.Respawn();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;
        _currentRespawnPoint = this;
    }


    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position + spawnPoint, 0.5f);
    }
}
