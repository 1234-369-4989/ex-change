using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;
using UnityEngine.Timeline;
using UnityEngine.UIElements;

public enum EnemyState{
    Idle,
    Chase,
    Attack
}


public class EnemyBehavior : MonoBehaviour
{

[Header("Movement Values")]    
public int MoveSpeed; //How fast the enemy moves
public int AttackDist; // How far away the enemy is to attack the player
public int MinDist;// Minimal Distance for the player to be noticed
public Transform Player; //Playerposition

[Header("Field of View Values")]
[Range(0,360)]
public float angle;//FOV angle
public LayerMask obstructionMask; //Mask for things the enemy can not see through 
public int CheckRadius;//How far is the Radius the Enemy can see
public LayerMask whatIsPlayer;//Layermask for defining what is the player
public bool canSeePlayer; //can the enemy see the player


[Header("Patrol Values")]
public List<Transform> Waypoints; //List of Patrolpoints
protected NavMeshAgent _agent;//Navmeshagent for Patrolling
[SerializeField] private int currentTarget;//which Point shall be reached next
private bool _reverse;//is the enemy travelling backwards in the List?
[SerializeField] private bool _targetReached;//is the current Target reached?

private bool _playerInSightRange, _playerInAttackRange;//is the Player in Attack/Sight Range


protected EnemyState _currentState;//current State in which the Enemy operates
private float _enemyHeight;//how how above the ground is the enemy floating
protected Vector3 velocity = Vector3.forward;// Velocity value for smoothdamp


private void Start()
{
    _currentState = EnemyState.Idle;
    _agent = GetComponent<NavMeshAgent>();
    _enemyHeight = transform.position.y;

    _agent.updateRotation = false;
    _agent.updatePosition = false;

    StartCoroutine(FOVRoutine());
}


private IEnumerator FOVRoutine()
{
    float delay = 0.2f;
    WaitForSeconds wait = new WaitForSeconds(delay);

    while (true)
    {
        yield return wait;
        FieldOfViewCheck();
    }
}


private void FieldOfViewCheck()
{
    Collider[] rangeChecks = Physics.OverlapSphere(transform.position, CheckRadius, whatIsPlayer);

    if (rangeChecks.Length != 0)//we are only looking for one object, if this does not work look that only the player has the Player Layer
    {
        Transform target = rangeChecks[0].transform;
        Vector3 directionTarget = (target.position - transform.position).normalized;

        if (Vector3.Angle(transform.forward, directionTarget) < angle / 2)
        {
            float distanceToTarget = Vector3.Distance(transform.position, target.position);
            
            //is nothing obscuring the player
            if (!Physics.Raycast(transform.position, directionTarget, distanceToTarget, obstructionMask))
            {
                canSeePlayer = true;
            }
            else//something is obscuring the player
            {
                canSeePlayer = false;
            }
        }
        else if(canSeePlayer)//when the player is not within the radius anymore unsee him
        {
            canSeePlayer = false;
        }
    }
}

/// <summary>
/// calculates whether the Player is in Attack Range, Sight Range or both. Sets the current State of the enemy accordingly
/// </summary>

    private void setCurrentState()
{
    _playerInSightRange = Physics.CheckSphere(transform.position, CheckRadius, whatIsPlayer);
    _playerInAttackRange = Physics.CheckSphere(transform.position, CheckRadius/2, whatIsPlayer);
    
    
    if (!_playerInSightRange && !_playerInAttackRange)
    {
        _currentState = EnemyState.Idle;
    }
    else if (_playerInSightRange && !_playerInAttackRange)
    {
        _currentState = EnemyState.Chase;
    }
    else if (_playerInSightRange && _playerInAttackRange)
    {
        _currentState = EnemyState.Attack;
    }
}
    
/// <summary>
/// gets the current State of the enemy every frame and makes adjustments accordingly
/// Idle: Walk the Patrol Route
/// Chase: Chase Player until in Attack Range
/// Attack: Attack Player
/// </summary>

private void FixedUpdate()
    {
        
        setCurrentState();
        Debug.Log(_currentState);

        switch (_currentState)
        {
            case EnemyState.Idle:
            {
                Patrol();
                break;
            }
            case EnemyState.Chase:
            {
                ChasePlayer();
                break;
            }
            case EnemyState.Attack:
            {
                Attack();
                break;
            }
            default: break;
        }
    }

/// <summary>
///Patrols the Transforms set in the List of Transforms given in Waypoints.
/// if target is reached wait, then go to the next
/// if end is reached reverse order
/// </summary>

private void Patrol()
    {
        float distance = Vector3.Distance(transform.position, Waypoints[currentTarget].position) - _enemyHeight;
        _agent.destination = Waypoints[currentTarget].position;
        transform.position = Vector3.SmoothDamp(transform.position, new Vector3(_agent.nextPosition.x, 0, _agent.nextPosition.z), ref velocity, 0.3f );
        if (distance < 1f && _targetReached == false)
        {
            _targetReached = true;

            if (_reverse == false)
            {
                currentTarget++;
            }
            else
            {
                currentTarget--;
            }

            if (currentTarget == Waypoints.Count - 1)
            {
                _reverse = true;
            }
            else if (currentTarget == 0)
            {
                _reverse = false;
            }
        }
        else if (distance < 1f && _targetReached)
        {
            StartCoroutine(WaitBeforeMoving());
        }
    }

IEnumerator RotateAgent(Quaternion currentRotation, Quaternion targetRotation)
{
    while (currentRotation != targetRotation)
    {
        transform.rotation =
            Quaternion.RotateTowards(currentRotation, targetRotation, _agent.angularSpeed * Time.fixedDeltaTime);
        yield return 1;
    }

}



/// <summary>
/// waits a time of 2f before moving on to the next Waypoint
/// </summary>
/// <returns></returns>

    protected virtual IEnumerator WaitBeforeMoving()
    {
        if (currentTarget == Waypoints.Count - 1 || currentTarget == 0)
        {
            yield return new WaitForSeconds(2f);
            _targetReached = false;
        }
        else
        {
            _targetReached = false;
        }
    }


/// <summary>
/// sets Player as primary Target and tries to reach him until in Attack Range
/// </summary>
    private void ChasePlayer()
    {
       transform.LookAt(Player);
       transform.position = Vector3.SmoothDamp(transform.position, new Vector3(_agent.nextPosition.x, 0, _agent.nextPosition.z), ref velocity, 0.3f );


       if (Vector3.Distance(transform.position, Player.position) >= MinDist)
       {
           _agent.destination = Player.position;
           
           if (Vector3.Distance(transform.position, Player.position) <= AttackDist)
           {
               _currentState = EnemyState.Attack;
           }
       }
    }
    /// <summary>
    /// attack the player
    /// </summary>
   public virtual void Attack()
    {
        //depends on how the enemy will attack
    }
}
