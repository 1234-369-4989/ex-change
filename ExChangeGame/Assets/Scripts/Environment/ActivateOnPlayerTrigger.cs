using UnityEngine;

namespace Environment
{
    [RequireComponent(typeof(Collider))]
    public abstract class ActivateOnPlayerTrigger : MonoBehaviour
    {
        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                Activate();
            }
        }
        protected abstract void Activate();
    }
}