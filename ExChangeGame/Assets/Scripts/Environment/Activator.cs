using System.Collections.Generic;
using UnityEngine;

namespace Environment
{
    // This script is responsible for activating a activatable object when the player enters the trigger
    public class Activator : MonoBehaviour
    {
        [SerializeField] private List<Activatable> activatables;
        [SerializeField] private bool isActivated;
        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                isActivated = !isActivated;
                foreach (var a in activatables)
                {
                    a.IsActivated = isActivated;
                }
            }
        }
    }
}
