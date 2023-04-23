using UnityEngine;

namespace ExChangeParts
{
    // Base class for all exchangeable parts
    public abstract class ExchangePart: MonoBehaviour, IExchangable
    {

        public enum PartType
        {
            Sensor, Utility, Movement, Design, Combat, Armor
        }
        
        public enum PartPosition
        {
            Front, Head, Back, Armor, Side, Other
        }
        
        [field: SerializeField] public PartType Type { get; protected set; }
        [field: SerializeField] public PartPosition Position { get; protected set; }
        
        public void Equip()
        {
            Debug.Log(name + " Equipped");
            OnEquip();
        }
        
        public void Unequip()
        {
            Debug.Log(name + " Unequipped");
            OnUnequip();
        }

        protected abstract void OnEquip();
        protected abstract void OnUnequip();
        
    }
}