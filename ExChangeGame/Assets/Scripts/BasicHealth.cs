using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class BasicHealth : MonoBehaviour
{
[field: SerializeField] public int Health { get; private set; }
[FormerlySerializedAs("MaxHealth")] [SerializeField] private int maxHealth;

public void Damage(int amount)
{
    if((Health -= amount) <= 0) gameObject.SetActive(false);
}

public void Heal(int amount)
{
    if ((Health += amount) >= maxHealth) Health = maxHealth;
}

}
