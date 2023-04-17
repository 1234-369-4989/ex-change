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
        
    }
    
    private void Attack()
    {
        
    }
}
