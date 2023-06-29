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
            transform.position = Vector3.SmoothDamp(transform.position, new Vector3(_agent.nextPosition.x, 0, _agent.nextPosition.z), ref velocity, 0.3f );
        }
    }
    
    private void OnDestroy()
    {
        //drop component here
        throw new NotImplementedException();
    }
}
