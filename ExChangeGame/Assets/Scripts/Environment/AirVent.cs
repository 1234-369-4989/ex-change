using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AirVent : MonoBehaviour
{
    [SerializeField] private List<VentEntrance> entrances;

    private WaitForSeconds waitForSeconds = new WaitForSeconds(1f);

    private void Start()
    {
        foreach (var entrance in entrances)
        {
            entrance.OnEnterVent += OnEnterVent;
        }
    }

    private void OnEnterVent(VentEntrance obj, GameObject player)
    {
        // set player position to the other entrance
        StartCoroutine(ShootOutPlayer(obj, player));
    }

    private IEnumerator ShootOutPlayer(VentEntrance obj, GameObject player)
    {
        var otherEntrance = entrances.Find(entrance => entrance != obj);
        otherEntrance.Collider.enabled = false;
        player.transform.GetChild(0).gameObject.SetActive(false);
        player.transform.position = otherEntrance.ExitPoint.position;
        yield return waitForSeconds;
        player.transform.GetChild(0).gameObject.SetActive(true);
        player.GetComponent<Rigidbody>().AddForce(otherEntrance.transform.forward * otherEntrance.ShootOutForce, ForceMode.VelocityChange);
        yield return waitForSeconds;
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
