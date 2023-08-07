using UnityEngine;

namespace ExChangeParts
{
    // The Grappling Hook
    public class Hook : ExchangePart
    {
        [SerializeField] private GrapplingHook grapplingHook;
        protected override void OnEquip()
        {
           grapplingHook.enabled = true;
           ExchangeSystem.Instance.Aiming = true;
           Debug.Log("Hook Equipped");
        }

        protected override void OnUnequip()
        {
           grapplingHook.enabled = false;
              ExchangeSystem.Instance.Aiming = false;
        }
    }
}