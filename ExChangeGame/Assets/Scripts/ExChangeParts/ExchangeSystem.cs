using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace ExChangeParts
{
    // The Exchange System is responsible for changing the parts of the robot
    public class ExchangeSystem : MonoBehaviour
    {
        [Header("Parts")]
        [SerializeField] private ExchangePart[] parts;
        [SerializeField] bool deactivateOnStart = true;
        [SerializeField] private ExchangePart[] defaultParts;
        
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
                    part.Unequip();
                    part.gameObject.SetActive(false);
                }
            }
            foreach (var part in defaultParts)
            {
                part.gameObject.SetActive(true);
                part.Equip();
            }
        }


        public void ChangePart(ExchangePart newPart)
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

        public bool HasPartEquipped(ExchangePart neededType)
        {
            return parts.Any(part => part.GetType() == neededType.GetType() && part.gameObject.activeSelf);
        }

        public void ChangePart(ExchangePart neededType, ExchangePart givenType)
        {
            RemovePart(neededType);
            ChangePart(givenType);
        }

        private void RemovePart(ExchangePart neededType)
        {
            foreach (var part in parts)
            {
                if (part.GetType() != neededType.GetType()) continue;
                if (!part.gameObject.activeSelf) continue;
                part.Unequip();
                part.gameObject.SetActive(false);
            }
        }

        public void ChangeParts(IList<ExchangePart> exchangeParts)
        {
            foreach (var part in exchangeParts)
            {
                ChangePart(part);
            }
        }
    }
}