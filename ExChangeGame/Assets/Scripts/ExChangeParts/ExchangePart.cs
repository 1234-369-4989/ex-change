using System;
using UnityEngine;

namespace ExChangeParts
{
    // Base class for all exchangeable parts
    [SelectionBase]
    public abstract class ExchangePart: MonoBehaviour, IExchangable
    {
        public static event Action<ExchangePart> OnPartEquipped;
        public enum PartType
        {
            Sensor, Utility, Movement, Design, Combat, Armor
        }
        
        public enum PartPosition
        {
            Front, Side, Top1, Top2
        }
        
        [field: SerializeField] public PartType Type { get; protected set; }
        [field: SerializeField] public PartPosition Position { get; protected set; }
        
        public void Equip()
        {
            // Debug.Log("Equipping " + gameObject.name);
            OnEquip();
            OnPartEquipped?.Invoke(this);
        }
        
        public void Unequip()
        {
            // Debug.Log("Unequipping " + gameObject.name);
            OnUnequip();
        }

        protected abstract void OnEquip();
        protected abstract void OnUnequip();
        
    }
}