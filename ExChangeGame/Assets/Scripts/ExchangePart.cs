using System;
using UnityEngine;

namespace DefaultNamespace
{
    public class ExchangePart : MonoBehaviour
    {
        public enum PartType
        {
           Cube, Sphere, Capsule, Cylinder
        }
        
        [field:SerializeField] public PartType Type { get; private set; }
        [field:SerializeField] public int ID { get; private set; }

        protected bool Equals(ExchangePart other)
        {
            return Type == other.Type && ID == other.ID;
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((ExchangePart) obj);
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(base.GetHashCode(), (int) Type, ID);
        }
    }
}