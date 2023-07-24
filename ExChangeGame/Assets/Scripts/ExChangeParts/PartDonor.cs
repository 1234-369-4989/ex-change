using ExChangeParts;
using UnityEngine;

public class PartDonor : MonoBehaviour
{
    [SerializeField] private ExchangePart part;

    public void DonatePart()
    {
        ExchangeSystem.Instance.ChangePart(part);
        part.gameObject.SetActive(false);
    }
}
