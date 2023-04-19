using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

public enum EnemyState{
    Idle,
    Chase,
    Attack
}


public class EnemyBehavior : MonoBehaviour
{

public int MoveSpeed;
public int AttackDist;
public int MinDist;
public Transform Player;

public int CheckRadius;
public LayerMask whatIsPlayer;

public List<Transform> Waypoints;
private NavMeshAgent _agent;
[SerializeField] private int currentTarget;
private bool _reverse;
[SerializeField] private bool _targetReached;

private bool _playerInSightRange, _playerInAttackRange;

private EnemyState _currentState = EnemyState.Idle;
private float _enemyHeight;


private void Start()
{
    _agent = GetComponent<NavMeshAgent>();
    _enemyHeight = transform.position.y;
}

private void Update()
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
        
        Debug.Log(_currentState);
        
        switch (_currentState)
        {
            case EnemyState.Idle:
            {
                LookForTargets();
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

    private void LookForTargets()
    {
        Patrol();
    }

    private void Patrol()
    {
        Debug.Log(_currentState);
        _agent.destination = Waypoints[currentTarget].position;
        float distance = Vector3.Distance(transform.position, Waypoints[currentTarget].position) - _enemyHeight;
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


    IEnumerator WaitBeforeMoving()
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
    

    private void ChasePlayer()
    {
       transform.LookAt(Player);

       if (Vector3.Distance(transform.position, Player.position) >= MinDist)
       {
           transform.position += transform.forward * (MoveSpeed * Time.deltaTime);
           
           if (Vector3.Distance(transform.position, Player.position) <= AttackDist)
           {
               _currentState = EnemyState.Attack;
           }
       }
    }
    
    private void Attack()
    {
        
    }
}
