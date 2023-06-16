using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SawEnemyBehavior : EnemyBehavior
{


    public override void Attack()
    {
        transform.LookAt(Player);

        if (Vector3.Distance(transform.position, Player.position) >= MinDist)
        {
            transform.position += transform.forward * (MoveSpeed * Time.deltaTime);
        }
    }
}
