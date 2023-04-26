using UnityEngine;

namespace ExChangeParts
{
    // The Exchange System is responsible for changing the parts of the robot
    public class ExchangeSystem : MonoBehaviour
    {
        [SerializeField] private ExchangePart[] parts;
        [SerializeField] bool deactivateOnStart = true;

        private void Start()
        {
            if (deactivateOnStart)
            {
                foreach (var part in parts)
                {
                    part.gameObject.SetActive(false);
                }
            }
        }


        public void ChangeParts(ExchangePart newPart)
        {
            foreach (var part in parts)
            {
                if (part.GetType() != newPart.GetType())
                {
                    if (part.Position == newPart.Position && part.gameObject.activeSelf)
                    {
                        part.Unequip();
                        part.gameObject.SetActive(false);
                    }
                    continue;
                }
                if(part.gameObject.activeSelf) continue;
                part.gameObject.SetActive(true);
                part.Equip();
            }
        }
    }
}