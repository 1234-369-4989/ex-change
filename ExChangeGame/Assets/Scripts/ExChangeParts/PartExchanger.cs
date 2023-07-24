using UnityEngine;

namespace ExChangeParts
{
    public class PartExchanger : MonoBehaviour
    {
        [SerializeField] private ExchangePart neededType;
        [SerializeField] private ExchangePart givenType;

        private void Awake()
        {
            if(neededType) neededType.gameObject.SetActive(false);
            if(givenType) givenType.gameObject.SetActive(true);
        }

        public void ExchangeParts()
        {
            if(!ExchangeSystem.Instance.HasPartEquipped(neededType)) return;
            ExchangeSystem.Instance.ChangePart(neededType, givenType);
            givenType.gameObject.SetActive(false);
            neededType.gameObject.SetActive(true);
        }
    }
}
