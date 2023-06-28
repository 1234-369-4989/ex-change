using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SawEnemyBehavior : EnemyBehavior
{


    public override void Attack()
    {
        transform.LookAt(Player);

        if (Vector3.Distance(transform.position, Player.position) >= AttackDist)
        {
            _agent.destination = Player.position;
        }
    }
    
    private void OnDestroy()
    {
        //drop component here
        throw new NotImplementedException();
    }
}
