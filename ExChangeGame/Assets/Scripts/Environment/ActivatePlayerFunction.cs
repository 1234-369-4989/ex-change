using UnityEngine;
using UnityEngine.Events;

// This script is responsible for activating a function when the player enters the trigger
namespace Environment
{
    public class ActivatePlayerFunction : MonoBehaviour
    {
    
        [SerializeField] private UnityEvent onActivate;
        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                onActivate.Invoke();
            }
        }
    }
}
