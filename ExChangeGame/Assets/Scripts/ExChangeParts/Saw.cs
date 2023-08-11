using UnityEngine;

namespace ExChangeParts
{
    [RequireComponent(typeof(Collider))]
    public class Saw : ExchangePart
    {
        
        [SerializeField] private float pushForceAway = 1f;
        [SerializeField] private float pushForceUp = 1f;
        [SerializeField] private AudioSource audioSource;

        private void OnTriggerEnter(Collider other)
        {
            if(!isPlayerPart) return;
            if (other.CompareTag("Player")) return;
            audioSource.Play();
            if (!other.TryGetComponent(out BasicHealth health)) return;
            Debug.Log("Saw hit");
            health.Damage(1);
            var direction = other.transform.position - transform.position;
            direction.y = 0;
            direction.Normalize();
            other.GetComponent<Rigidbody>().AddForce(direction * pushForceAway + Vector3.up * pushForceUp, ForceMode.VelocityChange);
        }

        protected override void OnEquip()
        {
      
        }

        protected override void OnUnequip()
        {
       
        }
    }
}
