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
    public float MeleeRange; //minimal radius away from Boss so he can shoot at player
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
    private bool _inMeleeRange;
    private bool _attacking;

    
    //hard coded Rotation for Attacking
    private Vector3 to = new Vector3(0, 40, 0);
    private Vector3 start = new Vector3(0, 0, 0);


    // Start is called before the first frame update
    void Start()
    {
        _agent = GetComponent<NavMeshAgent>();
        Animator = GetComponentInChildren<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
        Debug.Log(_attacking);
        if (!_attacking)
        {
            RotateToPoint(Player.transform.position);
            _inAttackRange = Physics.CheckSphere(transform.position, AttackRadius, whatIsPlayer);
            _inMeleeRange = Physics.CheckSphere(transform.position, MeleeRange, whatIsPlayer);
        }
    }

    private void FixedUpdate()
    {
        if (_inAttackRange)
        {
            if (!_inMeleeRange) _agent.destination = Player.transform.position;
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
           Animator.SetInteger("AttackIndex", Random.Range(1,4));
           Debug.Log(Animator.GetInteger("AttackIndex"));
           StartCoroutine(Attacking(Animator.GetInteger("AttackIndex")));
           StartCoroutine(returnToZero(TimeBetweenAttacks));
        }
        
        
    }

    IEnumerator Attacking(int index)
    {
        _attacking = true;
        Debug.Log(_attacking);
        _agent.destination = transform.position;
        if (Vector3.Distance(transform.rotation.eulerAngles, transform.rotation.eulerAngles + to) > 0.01f)
        {
            transform.eulerAngles = Vector3.Lerp(transform.rotation.eulerAngles, transform.rotation.eulerAngles + to, Time.deltaTime);
        }

        yield return new WaitForSeconds(4.0f);
        if(index == 3) ShootWithoutWaitTime();
        else Animator.SetTrigger("Attacking");
        _attacking = false;
    }

    IEnumerator returnToZero(float secs)
    {
        yield return new WaitForSeconds(secs);
        Animator.SetInteger("AttackIndex", 0);
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
