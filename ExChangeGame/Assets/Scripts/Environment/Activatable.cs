using UnityEngine;

namespace Environment
{
    // A class that can be activated
    public abstract class Activatable: MonoBehaviour
    {
        public abstract bool IsActivated { get; set; }
    }
}