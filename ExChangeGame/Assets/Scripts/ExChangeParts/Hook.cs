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
        }

        protected override void OnUnequip()
        {
           grapplingHook.enabled = false;
        }
    }
}