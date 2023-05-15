using UnityEngine;
using UnityEngine.Events;

// This script is responsible for activating a function when the player enters the trigger
namespace Environment
{
    public class ActivatePlayerFunction : ActivateOnPlayerTrigger
    {
        [SerializeField] private UnityEvent onActivate;

        protected override void Activate()
        {
            onActivate.Invoke();
        }
    }
}
