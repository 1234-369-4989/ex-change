using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ContactScript : MonoBehaviour
{
    [SerializeField] private float pushForceAway = 1f;
    [SerializeField] private float pushForceUp = 1f;
    [SerializeField] private int damage = 2;
    private void OnTriggerEnter(Collider other)
    {
        Debug.Log(other.tag);
        if (other.CompareTag("Player") || other.CompareTag("Enemy"))
        {
            Debug.Log("Player Hit");
            other.TryGetComponent<BasicHealth>(out var health);
            health.Damage(damage);
            Debug.Log(health);
            var direction = other.transform.position - transform.position;
            direction.Normalize();
            other.GetComponent<Rigidbody>().AddForce(direction * pushForceAway + Vector3.up * pushForceUp,
                ForceMode.VelocityChange);
            other.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeRotation;
        }
        
        Destroy(gameObject);
    }
}
