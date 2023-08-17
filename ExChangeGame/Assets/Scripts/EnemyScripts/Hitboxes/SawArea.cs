using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class SawArea : MonoBehaviour
{
        [SerializeField] private float pushForceAway = 1f;
       [SerializeField] private float pushForceUp = 1f;
       [SerializeField] private int Damage = 1;
       
       private AudioSource _audioSource;
       
         private void Awake()
         {
              _audioSource = GetComponent<AudioSource>();
         }

       /// <summary>
       /// simple Hitbox Script, which reduces the health of the other object and applies knockback
       /// </summary>
       /// <param name="other"></param>
       private void OnTriggerEnter(Collider other)
       {
           if (!other.TryGetComponent<BasicHealth>(out var health)) return;
           Debug.Log("Saw Hit", other.gameObject);
           health.Damage(Damage);
           _audioSource.Play();
           Debug.Log(health);
           var direction = other.transform.position - transform.position;
           direction.Normalize();
           other.GetComponent<Rigidbody>().AddForce(direction * pushForceAway + Vector3.up * pushForceUp,
               ForceMode.VelocityChange);
           other.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeRotation;
       }
}
