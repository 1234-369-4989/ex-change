using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

public enum EnemyState{
    Idle,
    Chase,
    Attack
}

public class EnemyBehavior : MonoBehaviour
{

public int MoveSpeed;
public int MaxDist;
public int MinDist;
public Transform Player;

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
        
    }

    private void CalculateMovement()
    {
       transform.LookAt(Player);

       if (Vector3.Distance(transform.position, Player.position) >= MinDist)
       {
           transform.position += transform.forward * MoveSpeed * Time.deltaTime;
           
           if (Vector3.Distance(transform.position, Player.position) <= MaxDist)
           {
               _currentState = EnemyState.Attack;
           }
       }
    }
    
    private void Attack()
    {
        
    }
}
