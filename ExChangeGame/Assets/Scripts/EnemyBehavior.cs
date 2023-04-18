using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
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
public LayerMask whatIsGround, whatIsPlayer;

private bool _playerInSightRange, _playerInAttackRange;

[SerializeField] private EnemyState _currentState = EnemyState.Idle;

    private void Update()
    {
        switch (_currentState)
        {
            case EnemyState.Idle:
            {
                LookForTargets();
                break;
            }
            case EnemyState.Chase:
            {
                CalculateMovement();
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
        _playerInSightRange = Physics.CheckSphere(transform.position, CheckRadius, whatIsPlayer);
        _playerInAttackRange = Physics.CheckSphere(transform.position, AttackDist, whatIsPlayer);
        if (_playerInSightRange && !_playerInAttackRange)
        {
            _currentState = EnemyState.Chase;
        }

        if (_playerInSightRange && _playerInAttackRange)
        {
            _currentState = EnemyState.Attack;
        }
    }

    private void CalculateMovement()
    {
       transform.LookAt(Player);

       if (Vector3.Distance(transform.position, Player.position) >= MinDist)
       {
           transform.position += transform.forward * MoveSpeed * Time.deltaTime;
           
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
