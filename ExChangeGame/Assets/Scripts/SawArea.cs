using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class SawArea : MonoBehaviour
{
      [SerializeField] private float damagePerSecond = 1f;
       [SerializeField] private float pushForceAway = 1f;
       [SerializeField] private float pushForceUp = 1f;
       private void OnTriggerEnter(Collider other)
       {
           if(!other.TryGetComponent<BasicHealth>(out var health)) return; ;
           health.Damage(1);
           var direction = other.transform.position - transform.position;
           direction.y = 0;
           direction.Normalize();
           other.GetComponent<Rigidbody>().AddForce(direction * pushForceAway + Vector3.up * pushForceUp, ForceMode.VelocityChange);
   } 
       private void OnTriggerStay(Collider other)
       {
           if(!other.TryGetComponent<BasicHealth>(out var health)) return;
           health.Damage((int) (damagePerSecond * Time.deltaTime));
       }
}
