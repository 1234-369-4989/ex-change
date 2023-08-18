using UnityEngine;

public class SawEnemyBehavior : EnemyBehavior
{
    
    [SerializeField] private AudioSource idleSound;
    [SerializeField] private AudioSource deathSound;

/// <summary>
/// this enemy tries to "drive" the player to death
/// </summary>
    public override void Attack()
    {
        RotateToPoint(Player.transform.position);

        if (Vector3.Distance(transform.position, Player.position) >= AttackDist)
        {
            if (_agent.isStopped) _agent.isStopped = false;
            Debug.Log("Attacking Player");
            _agent.destination = Player.position;
            _agent.transform.position = Vector3.SmoothDamp(transform.position, new Vector3(_agent.nextPosition.x, 0, _agent.nextPosition.z), ref velocity, 0.3f );
        }
    }

    protected override void OnDeath(BasicHealth h)
    {
        base.OnDeath(h);
        idleSound.Stop();
    }
    
    protected override void HandleLevelChange(int floor)
    {
        base.HandleLevelChange(floor);
        idleSound.mute = floor != floorLayer;
    }
}
