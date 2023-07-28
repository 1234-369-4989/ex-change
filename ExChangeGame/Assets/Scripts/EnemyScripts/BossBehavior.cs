using System;
using System.Collections;
using System.Collections.Generic;
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

    
    //private variables
    private NavMeshAgent _agent;
    private bool _inAttackRange;
    private bool _inShootingRange;



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
        else// when completely out of range shoot one last time, then drive at player
        {
            Shoot();
            _agent.destination = Player.transform.position;
        }
    }

    private void RandomizedAttackPattern()
    {
        int random;
        if (_inShootingRange) random = Random.Range(0, 2);
        else random = Random.Range(0, 1);//only melee when outside minimal shooting range

        switch (random)
        {
            case 0: Stab();
                break;
            case 1: Slash();
                break;
            case 2: Shoot();
                break;
            default: RandomizedAttackPattern();
                break;
        }
    }

    private void Stab()
    {
        Animator.SetTrigger("isStabbing");
    }

    private void Slash()
    {
        Animator.SetTrigger("isSlashing");
    }


    private void Shoot()
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

    private void Melee()
    {
        Debug.Log("Melee");
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
