using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

[RequireComponent(typeof(BasicHealth))]
public class BossBehavior : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private GameObject Player;
    public float AttackRadius; 
    public float MeleeRange; //minimal radius away from Boss so he can shoot at player
    [SerializeField] private LayerMask whatIsPlayer;
    [SerializeField] private Animator Animator;
    [SerializeField] public bool Hostile;

    [Header("Shooting Variables")]
    [SerializeField] private float timer = 5f;
    [SerializeField] private float bulletSpeed = 5f;
    private float _bulletTime;
    public GameObject EnemyBullet;
    public Transform SpawnPoint;

    [Header("Attacking Variables")]
    [SerializeField] private float TimeBetweenAttacks;

    [Header("Health")]
    [SerializeField] private EnemyHealth enemyHealth;
    [SerializeField] private AudioSource deathAudioSource;
    [SerializeField] private GameObject deathEffect;
    [SerializeField] private GameObject graphics;
    [SerializeField] private AudioSource idleSound;
    [SerializeField] private AudioSource deathSound;
    [SerializeField] private AudioSource shootSound;
    [SerializeField] private AudioSource sawSound;
    [SerializeField] private AudioSource tauntingSound;
    private BasicHealth _health;

    [Header("WorldSettings")]
    [SerializeField] protected int floorLayer;
    
    //private variables
    private NavMeshAgent _agent;
    private bool _inAttackRange;
    private bool _inMeleeRange;
    private bool _attacking;
    private bool _isPlayerDead;


    private void Awake()
    {
        _health = GetComponent<BasicHealth>();
        _health.OnDeath += OnDeath;
        _health.OnDamage += OnDamage;
        PlayerInstance.OnPlayerDeath += HandlePlayerDeath;
        PlayerInstance.OnPlayerRespawn += HandlePlayerRespawn;
        MinimapCamera.OnOnLevelChange += HandleLevelChange;
    }

    protected virtual void HandleLevelChange(int floor)
    {
        idleSound.mute = floor != floorLayer;
    }

    // Start is called before the first frame update
    void Start()
    {
        _agent = GetComponent<NavMeshAgent>();
        Animator = GetComponentInChildren<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        Debug.Log(_inMeleeRange);
        if (Hostile)
        {
            if (!_attacking)
            {
                _inAttackRange = !_isPlayerDead && Physics.CheckSphere(transform.position, AttackRadius, whatIsPlayer);
                _inMeleeRange = !_isPlayerDead && Physics.CheckSphere(transform.position, MeleeRange, whatIsPlayer);
            }
        }
      
    }

    private void FixedUpdate()
    {
        if (Hostile)
        {
            RotateToPoint(Player.transform.position);
            if (_inAttackRange)
            {
                if (!_inMeleeRange) _agent.destination = Player.transform.position;
                else RandomizedAttackPattern();// in Melee Range
            }
            else// when completely out of range shoot one last time, then follow player
            {
                ShootAfterWaitTime();
                _agent.destination = Player.transform.position;
            } 
        }
       
    }

    /// <summary>
    /// this attack randomly picks an Integer and attacks depending on the State Machine in the Animator
    /// </summary>
    private void RandomizedAttackPattern()
    {
        if (Animator.GetInteger("AttackIndex") == 0)
        {
            Debug.Log("Attacking");
           _attacking = true;
           Animator.SetInteger("AttackIndex", Random.Range(1,4));
           Debug.Log(Animator.GetInteger("AttackIndex"));
           if(Animator.GetInteger("AttackIndex") == 3) ShootWithoutWaitTime();
           else Animator.SetTrigger("Attacking");
           StartCoroutine(returnToZero(TimeBetweenAttacks));
        }
        
        
    }

    
    /// <summary>
    /// this resets all necessary variables after the animation is finished
    /// </summary>
    /// <param name="secs"></param>
    /// <returns></returns>
    IEnumerator returnToZero(float secs)
    {
        yield return new WaitForSeconds(secs);
        Animator.SetInteger("AttackIndex", 0);
        _attacking = false;
    }



    /// <summary>
    /// This method shoots at the Player after a certain time is finished
    /// </summary>
    
    private void ShootAfterWaitTime()
    {
        _agent.destination = transform.position;
        _bulletTime -= Time.deltaTime;

        if (_bulletTime > 0) return;//do not shoot until "charging" complete

        _bulletTime = timer;

        shootSound.Play();
        GameObject bulletObject =
            Instantiate(EnemyBullet, SpawnPoint.transform.position, transform.rotation);
        Rigidbody bulletRigidbody = bulletObject.GetComponent<Rigidbody>();
        
        
        Vector3 direction = Player.transform.position - SpawnPoint.transform.position;
        direction.Normalize();
        bulletRigidbody.AddForce(direction * bulletSpeed, ForceMode.Impulse);
    }
    
    /// <summary>
    /// this method shoots at the Player without a "charging up" time
    /// </summary>

    private void ShootWithoutWaitTime()
    {
        shootSound.Play();
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
        //find the vector pointing from our position to the target
        var _direction = (Player.transform.position - transform.position).normalized;

        //create the rotation we need to be in to look at the target
        var _lookRotation = Quaternion.LookRotation(_direction);

        //rotate us over time according to speed until we are in the required rotation
        transform.rotation = Quaternion.Slerp(transform.rotation, _lookRotation, Time.deltaTime * (_agent.speed/2));
    }

    protected virtual void OnDeath(BasicHealth h)
    {
        StartCoroutine(DeathCoroutine());
        idleSound.Stop();
    }

    public IEnumerator Taunt()
    {
        Animator.Play("Slash");
        tauntingSound.Play();
        yield return new WaitForSeconds(1.5f);
    }

    private IEnumerator DeathCoroutine()
    {
        deathEffect.SetActive(true);
        this.enabled = false;
        graphics.SetActive(false);
        deathAudioSource.Play();
        yield return new WaitForSeconds(2f);
        gameObject.SetActive(false);
    }

    protected virtual void OnDamage(BasicHealth h)
    {
        enemyHealth.UpdateHealthBar(h.Health, h.MaxHealth);
    }

    private void HandlePlayerRespawn()
    {
        SetPlayerDead(false);
    }

    private void HandlePlayerDeath()
    {
        SetPlayerDead(true);
    }
    
    private void SetPlayerDead(bool b)
    {
        _isPlayerDead = b;
        Hostile = false;
    }

    private void OnDisable()
    {
        _agent.enabled = false;
        _health.OnDeath -= OnDeath;
        _health.OnDamage -= OnDamage;
    }

    private void OnDestroy()
    {
        PlayerInstance.OnPlayerDeath -= HandlePlayerDeath;
        PlayerInstance.OnPlayerRespawn -= HandlePlayerRespawn;
        MinimapCamera.OnOnLevelChange -= HandleLevelChange;
    }
    
    
}
