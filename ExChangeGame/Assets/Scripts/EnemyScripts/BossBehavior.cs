using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

public class BossBehavior : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private GameObject Player;
    public float AttackRadius;
    public float ShootingRadius; //minimal radius away from Boss so he can shoot at player
    [SerializeField] private LayerMask whatIsPlayer;
    [SerializeField] private Animator Animator;

    [Header("Shooting Variables")]
    [SerializeField] private float timer = 5f;
    [SerializeField] private float bulletSpeed = 5f;
    private float _bulletTime;
    public GameObject EnemyBullet;
    public Transform SpawnPoint;

    [Header("AttackingVariables")]
    [SerializeField] private float TimeBetweenAttacks;

    
    //private variables
    private NavMeshAgent _agent;
    private bool _inAttackRange;
    private bool _inShootingRange;
    private bool _attacking;



    // Start is called before the first frame update
    void Start()
    {
        _agent = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    void Update()
    {
        RotateToPoint(Player.transform.position);
        _inAttackRange = Physics.CheckSphere(transform.position, AttackRadius, whatIsPlayer);
    }

    private void FixedUpdate()
    {
        if (_inAttackRange)
        {
            _inShootingRange = !Physics.CheckSphere(transform.position, ShootingRadius, whatIsPlayer);// check if Player is within minimal radius
            _agent.destination = transform.position;
            RandomizedAttackPattern();
        }
        else// when completely out of range shoot one last time, then follow player
        {
            ShootAfterWaitTime();
            _agent.destination = Player.transform.position;
        }
    }

    private void RandomizedAttackPattern()
    {
        if (Animator.GetInteger("AttackIndex") == 0)
        {
            if(_inShootingRange) Animator.SetInteger("AttackIndex", Random.Range(1,4));// if he could shoot include shoot
            else Animator.SetInteger("AttackIndex", Random.Range(1,3));//if not do not include shoot

                Debug.Log(Animator.GetInteger("AttackIndex"));
            
            if (Animator.GetInteger("AttackIndex") == 3 && _inShootingRange) ShootWithoutWaitTime();
            else
            {
                _attacking = true;
                Animator.SetTrigger("Attacking");
            }
            
            StartCoroutine(returnToZero(TimeBetweenAttacks));
        }
        
        
    }

    IEnumerator returnToZero(float secs)
    {
        yield return new WaitForSeconds(secs);
        Animator.SetInteger("AttackIndex", 0);
        _attacking = false;
    }



    private void ShootAfterWaitTime()
    {
        _agent.destination = transform.position;
        _bulletTime -= Time.deltaTime;

        if (_bulletTime > 0) return;//do not shoot until "charging" complete

        _bulletTime = timer;

        GameObject bulletObject =
            Instantiate(EnemyBullet, SpawnPoint.transform.position, transform.rotation);
        Rigidbody bulletRigidbody = bulletObject.GetComponent<Rigidbody>();
        
        Vector3 direction = Player.transform.position - SpawnPoint.transform.position;
        direction.Normalize();
        bulletRigidbody.AddForce(direction * bulletSpeed, ForceMode.Impulse);
    }

    private void ShootWithoutWaitTime()
    {
        GameObject bulletObject =
            Instantiate(EnemyBullet, SpawnPoint.transform.position, transform.rotation);
        Rigidbody bulletRigidbody = bulletObject.GetComponent<Rigidbody>();
        
        Vector3 direction = Player.transform.position - SpawnPoint.transform.position;
        direction.Normalize();
        bulletRigidbody.AddForce(direction * bulletSpeed, ForceMode.Impulse);
    }


    /// <summary>
    /// Rotate Transform until looking at Point
    /// </summary>
    /// <param name="target">target to look at</param>
    private void RotateToPoint(Vector3 target)
    {
        Vector3 targetDirection = target - transform.position;
                
        float SingleStep = _agent.angularSpeed * Time.fixedDeltaTime;
        Vector3 newDirection = Vector3.RotateTowards(transform.forward, targetDirection, SingleStep, 0.0f);
        newDirection.y = 0;//lock rotation in x-z plane
        transform.rotation = Quaternion.LookRotation(newDirection); 
    }
}
