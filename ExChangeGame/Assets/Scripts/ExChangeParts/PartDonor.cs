using Environment;
using ExChangeParts;
using UnityEngine;

public class PartDonor : ActivateOnPlayerTrigger
{
    [SerializeField] private ExchangePart part;

    protected override void Activate()
    {
        ExchangeSystem.Instance.ChangeParts(part);
        part.gameObject.SetActive(false);
    }
}
