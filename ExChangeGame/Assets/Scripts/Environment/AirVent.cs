using System.Collections;
using System.Collections.Generic;
using Movement;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class  AirVent : MonoBehaviour
{
    [SerializeField] private List<VentEntrance> entrances;
    [SerializeField] private float fadeTime = 1;
    [SerializeField] private float inFadeTime = 1;
    [SerializeField] private float shootTime = 1;
    
    [Header("Sound")]
    private AudioSource _audioSource;

    private WaitForSeconds _waitForShoot;
    private WaitForSeconds _waitforFade;
    private WaitForSeconds _waitInFade;
    

    private void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        foreach (var entrance in entrances)
        {
            entrance.OnEnterVent += OnEnterVent;
        }
        _waitforFade = new WaitForSeconds(fadeTime);
        _waitInFade = new WaitForSeconds(inFadeTime);
        _waitForShoot = new WaitForSeconds(shootTime);
    }

    private void OnEnterVent(VentEntrance obj, MovementRigidbody player)
    {
        // set player position to the other entrance
        StartCoroutine(TransferPlayer(obj, player));
    }

    private IEnumerator TransferPlayer(VentEntrance firstVent, MovementRigidbody player)
    {
        var playerTransform = player.transform;
        var otherEntrance = entrances.Find(entrance => entrance != firstVent);
        otherEntrance.Collider.enabled = false;
        playerTransform.GetChild(0).gameObject.SetActive(false);
        player.CanMove = false;
        _audioSource.Play();
        Overlay.Instance.FadeIn(fadeTime);
        yield return _waitforFade;
        playerTransform.position = otherEntrance.ExitPoint.position;
        yield return _waitInFade;
        Overlay.Instance.FadeOut(fadeTime);
        yield return _waitforFade;
        playerTransform.GetChild(0).gameObject.SetActive(true);
        player.GetComponent<Rigidbody>().AddForce(otherEntrance.transform.forward * otherEntrance.ShootOutForce, ForceMode.VelocityChange);
        player.CanMove = true;
        yield return _waitForShoot;
        otherEntrance.Collider.enabled = true;
    }

    private void OnDestroy()
    {
        foreach (var entrance in entrances)
        {
            entrance.OnEnterVent -= OnEnterVent;
        }
    }
}
