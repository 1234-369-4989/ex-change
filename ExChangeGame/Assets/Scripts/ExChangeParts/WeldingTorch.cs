using System;
using StarterAssets;
using UnityEngine;
using UnityEngine.InputSystem;

namespace ExChangeParts
{
    // the welding torch should allow the robot to repair other objects in the world
    public class WeldingTorch : ExchangePart
    {
        [SerializeField] PlayerInput input;
        [SerializeField] private float repairDistance = 5f;
        
        bool canRepair;
            
        private void OnRepair(InputAction.CallbackContext obj)
        {
            print("Repairing");
            if (!canRepair) return;
            if (!Physics.Raycast(transform.position, transform.forward, out var hit, repairDistance)) return;
            var repairable = hit.collider.GetComponent<RepairableObject>();
            if (repairable == null) return;
            repairable.Repair();
        }

        protected override void OnEquip()
        {
            canRepair = true;
            input.actions["Repair"].performed += OnRepair;
        }

        protected override void OnUnequip()
        {
           canRepair = false; 
           input.actions["Repair"].performed -= OnRepair;
        }
        
        private void OnDestroy()
        {
            if(!input) return;
           input.actions["Repair"].performed -= OnRepair;
        }
    }
}