using UnityEngine;

namespace ExChangeParts
{
    // The Exchange System is responsible for changing the parts of the robot
    public class ExchangeSystem : MonoBehaviour
    {
        [Header("Parts")]
        [SerializeField] private ExchangePart[] parts;
        [SerializeField] bool deactivateOnStart = true;
        
        [Header("Visuals")]
        [SerializeField] private Renderer[] colorRenderers;
        public static ExchangeSystem Instance { get; private set; }
        
        //OnMovementChange event
        public delegate void OnMovement(MovementVariables movementVariables);
        public OnMovement OnMovementChanged;

        private void Awake()
        {
            if (Instance == null)
                Instance = this;
            else
                Destroy(gameObject);
        }

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

                if (part.gameObject.activeSelf) continue;
                part.gameObject.SetActive(true);
                part.Equip();
            }
        }
        
        public void ChangeColor(Color color)
        {
            foreach (var ren in colorRenderers)
            {
                var sharedMaterial = ren.sharedMaterial;
                var mat = new Material(sharedMaterial)
                {
                    color = color
                };
                sharedMaterial = mat;
                ren.sharedMaterial = sharedMaterial;
            }
        }

        public void SetMovement(MovementVariables movementVariables)
        {
            OnMovementChanged?.Invoke(movementVariables);
        }
    }
}