using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicHealth
{
public GameObject Object;
public int Health;
public int MaxHealth;

public void Damage(int amount)
{
    if((Health -= amount) <= 0) GameObject.Destroy(Object);
}

public void Heal(int amount)
{
    if ((Health += amount) >= MaxHealth) Health = MaxHealth;
}

}
