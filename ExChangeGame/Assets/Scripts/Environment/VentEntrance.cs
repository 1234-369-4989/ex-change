using System;
using Movement;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class VentEntrance : MonoBehaviour
{
    [field: SerializeField] public Transform ExitPoint { get; private set; }
    [field: SerializeField] public float ShootOutForce { get; private set; } = 5f;
    public event Action<VentEntrance, MovementRigidbody> OnEnterVent;
    
    public Collider Collider { get; private set; }

    private void Awake()
    {
        Collider = GetComponent<Collider>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent<MovementRigidbody>(out var player))
        {
            OnEnterVent?.Invoke(this, player);
        }
    }
}
