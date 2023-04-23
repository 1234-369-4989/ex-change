using System;
using UnityEngine;

namespace ExChangeParts
{
    // Armor should reduce damage taken
    public class Armor : ExchangePart
    {
        [SerializeField] private GameObject armorModel;
        [SerializeField] private int initialArmorValue;
        [field: SerializeField] public int ArmorValue { get; private set;}
        
        private void Start()
        {
            Type = PartType.Armor;
        }

        protected override void OnEquip()
        {
            armorModel.SetActive(true);
            ArmorValue = initialArmorValue;
        }

        protected override void OnUnequip()
        {
            armorModel.SetActive(false);
            ArmorValue = 0;
        }
        
        // returns the remaining damage after the armor has taken it
        public int TakeDamage(int damage)
        {
            ArmorValue -= damage;
            if (ArmorValue <= 0)
            {
                armorModel.SetActive(false);
                return Math.Abs(ArmorValue);
            }
            return 0;
        }
    }
}