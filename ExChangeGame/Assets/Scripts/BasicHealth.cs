using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class BasicHealth : MonoBehaviour
{
[field: SerializeField] public int Health { get; private set; }
[FormerlySerializedAs("MaxHealth")] [SerializeField] private int maxHealth;
[SerializeField] private FloatingEnemyHealth floatingEnemyHealth;
public void Damage(int amount)
{
    Health -= amount;
    if(floatingEnemyHealth != null) floatingEnemyHealth.UpdateHealthBar(Health, maxHealth);
    if((Health) <= 0) gameObject.SetActive(false);
}

public void Heal(int amount)
{
    if(floatingEnemyHealth != null) floatingEnemyHealth.UpdateHealthBar(Health, maxHealth);
    if ((Health += amount) >= maxHealth) Health = maxHealth;
}

}
