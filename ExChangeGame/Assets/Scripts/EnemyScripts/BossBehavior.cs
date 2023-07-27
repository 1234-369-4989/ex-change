using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Random = UnityEngine.Random;

public class BossBehavior : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private GameObject Player;
    public float ShootRadius;
    public float CQCRadius;
    [SerializeField] private LayerMask whatIsPlayer;
   
    [Header("Shooting Variables")]
    [SerializeField] private float timer = 5f;
    [SerializeField] private float bulletSpeed = 5f;
    private float _bulletTime;
    public GameObject EnemyBullet;
    public Transform SpawnPoint;

    
    //private variables
    private NavMeshAgent _agent;
    private Animator _animator;
    private bool _inShootingRange;
    private bool _inCQCRange; //_inCloseQuartersCombatRange
    private bool _isShooting;
    private bool _isCQCing;
    
    
    
    // Start is called before the first frame update
    void Start()
    {
        _agent = GetComponent<NavMeshAgent>();
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(Player.transform.position);
        if (!_isShooting && !_isCQCing)
        {
            CheckRadius();
            
        }
    }

    private void FixedUpdate()
    {
        if (_inShootingRange && !_inCQCRange)
        {
            Shoot();
        }
        else if (_inShootingRange && _inCQCRange)
        {
            Melee();
        }
        else// when completely out of range drive at player
        {
            _agent.destination = Player.transform.position;
        }
    }

    private void CheckRadius()
    {
        if (!_isShooting || !_isCQCing)
        {
            _inShootingRange = Physics.CheckSphere(transform.position, ShootRadius, whatIsPlayer);
            _inCQCRange = Physics.CheckSphere(transform.position, CQCRadius, whatIsPlayer); 
        }
        
    }

    private void Shoot()
    {
        _isShooting = true;
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
        _isShooting = false;
    }

    private void Melee()
    {
        _isCQCing = true;
        _agent.destination = transform.position;
        int random = Random.Range(0, 1);
        Debug.Log(random);
        if(random == 1) _animator.SetTrigger("isSlashing");
        else if(random == 0) _animator.SetTrigger("isStabbing");
        _isCQCing = false;
    }
}
