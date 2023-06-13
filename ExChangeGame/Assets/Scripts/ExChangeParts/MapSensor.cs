using System;
using UnityEngine;

namespace ExChangeParts
{
    // antennas should trigger the UI minimap
    public class MapSensor: ExchangePart
    {
        
        [SerializeField] private GameObject minimap;

        
        private void Start()
        {
            // UI minimap inactive
            // if(minimap)minimap.SetActive(false);
        }

        protected override void OnEquip()
        {
            // UI minimap active
            minimap.SetActive(true);
        }

        protected override void OnUnequip()
        {
            // UI minimap inactive
            minimap.SetActive(false);
        }
    }
}