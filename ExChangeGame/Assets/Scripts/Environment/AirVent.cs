using System.Collections;
using System.Collections.Generic;
using Movement;
using UnityEngine;
using UnityEngine.Serialization;

public class  AirVent : MonoBehaviour
{
    [SerializeField] private List<VentEntrance> entrances;
    [SerializeField] private float fadeTime = 1;
    [SerializeField] private float inFadeTime = 1;
    [SerializeField] private float shootTime = 1;

    private WaitForSeconds waitForShoot;
    private WaitForSeconds waitforFade;
    private WaitForSeconds waitInFade;
    

    private void Start()
    {
        foreach (var entrance in entrances)
        {
            entrance.OnEnterVent += OnEnterVent;
        }
        waitforFade = new WaitForSeconds(fadeTime);
        waitInFade = new WaitForSeconds(inFadeTime);
        waitForShoot = new WaitForSeconds(shootTime);
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
        Overlay.Instance.FadeIn(fadeTime);
        yield return waitforFade;
        playerTransform.position = otherEntrance.ExitPoint.position;
        yield return waitInFade;
        Overlay.Instance.FadeOut(fadeTime);
        yield return waitforFade;
        playerTransform.GetChild(0).gameObject.SetActive(true);
        player.GetComponent<Rigidbody>().AddForce(otherEntrance.transform.forward * otherEntrance.ShootOutForce, ForceMode.VelocityChange);
        player.CanMove = true;
        yield return waitForShoot;
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
