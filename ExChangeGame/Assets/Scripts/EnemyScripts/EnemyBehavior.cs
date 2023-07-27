
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public enum EnemyState
{
    Idle,
    Chase,
    Attack
}

[RequireComponent(typeof(BasicHealth))]
public class EnemyBehavior : MonoBehaviour
{
    [Header("Movement Values")]
    public int AttackDist; // How far away the enemy is to attack the player
    public int MinDist; // Minimal Distance for the player to be noticed
    protected Transform Player; //Playerposition

    [Header("Field of View Values")] [Range(0, 360)]
    public float angle; //FOV angle
    public int CheckRadius; //How far is the Radius the Enemy can see
    public LayerMask obstructionMask; //Mask for things the enemy can not see through 
    public LayerMask whatIsPlayer; //Layermask for defining what is the player
    public bool canSeePlayer; //can the enemy see the player


    [Header("Patrol Values")] public List<Transform> Waypoints; //List of Patrolpoints
    protected NavMeshAgent _agent; //Navmeshagent for Patrolling
    [SerializeField] protected int currentTarget; //which Point shall be reached next
    private bool _reverse; //is the enemy travelling backwards in the List?
    [SerializeField] protected bool _targetReached; //is the current Target reached?

    private bool _playerInSightRange, _playerInAttackRange; //is the Player in Attack/Sight Range


    protected EnemyState _currentState; //current State in which the Enemy operates
    private float _enemyHeight; //how how above the ground is the enemy floating
    protected Vector3 velocity = Vector3.forward; // Velocity value for smoothdamp
    private Coroutine LookCoroutine;
    
    [Header("Do you want your own Rotation?")]
    public bool DefaultRotation;
    
    [Header("Health")]
    [SerializeField] private EnemyHealth enemyHealth;
    private BasicHealth _health;
    

    private void Awake()
    {
        _health = GetComponent<BasicHealth>();
        _health.OnDeath += OnDeath;
        _health.OnDamage += OnDamage;
    }


    private void Start()
    {
        Player = PlayerInstance.Instance.transform;
        _currentState = EnemyState.Idle;
        _agent = GetComponent<NavMeshAgent>();
        _enemyHeight = transform.position.y;
        
        if(!DefaultRotation) _agent.updateRotation = false;

        
        _agent.updatePosition = false;

        StartCoroutine(FOVRoutine());
    }

    /// <summary>
    /// Checks if the player is within the Enemie's FOV
    /// </summary>
    /// <returns></returns>
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

    /// <summary>
    /// This Coroutine checks whether our player is inside the FOV of our enemy or not
    /// </summary>
    private void FieldOfViewCheck()
    {
        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, CheckRadius, whatIsPlayer);

        if (rangeChecks.Length != 0) //we are only looking for one object, if this does not work look that only the player has the Player Layer
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
                else //something is obscuring the player
                {
                    canSeePlayer = false;
                }
            }
        }
        else if (canSeePlayer == true) //when the player is not within the radius anymore unsee him
        {
            canSeePlayer = false;
        }
    }

    /// <summary>
    /// calculates whether the Player is in Attack Range, Sight Range or both. Sets the current State of the enemy accordingly
    /// </summary>
    private void setCurrentState()
    {
        _playerInAttackRange = Physics.CheckSphere(transform.position, CheckRadius / 2, whatIsPlayer);


        if (!canSeePlayer && !_playerInAttackRange)
        {
            _currentState = EnemyState.Idle;
        }
        else if (canSeePlayer && !_playerInAttackRange)
        {
            _currentState = EnemyState.Chase;
        }
        else if (canSeePlayer && _playerInAttackRange)
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

        switch (_currentState)
        {
            case EnemyState.Idle:
            {
                if(Waypoints.Count > 0) Patrol();
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
    /// Checks if a value is between two parameters. Can be used in both ways
    /// </summary>
    /// <param name="min"> Minimal or Maximal Border</param>
    /// <param name="max"> Minimal or Maximal Border</param>
    /// <param name="value">Checked Value</param>
    /// <returns>whether the value is in between min and max</returns>
    private static bool IsValueBetween(float min, float max, float value){
        return ((min < value) && (value < max)) || ((max < value) && (value < min));
    }

    /// <summary>
    ///Patrols the Transforms set in the List of Transforms given as Waypoints.
    /// if target is reached wait, then go to the next
    /// if end is reached reverse order
    /// </summary>
    private void Patrol()
    {
        float distance = Vector3.Distance(transform.position, Waypoints[currentTarget].position) - _enemyHeight;
        _agent.destination = Waypoints[currentTarget].position;
        transform.position = Vector3.SmoothDamp(transform.position,
                new Vector3(_agent.nextPosition.x, 0, _agent.nextPosition.z), ref velocity, 0.3f);

        Vector3 target = _agent.pathEndPosition;
        Vector3 directionTarget = (target - transform.position).normalized;
        
        Debug.Log(Vector3.Angle(transform.forward, directionTarget));

        if (!DefaultRotation)
        {
            
            if (!IsValueBetween(0f, 5f, Vector3.Angle(transform.forward, directionTarget)))
            {
                _agent.isStopped = true;//Stop the Agent while Rotating

                RotateToPoint(target);
            }
            else
            {
                _agent.isStopped = false;//Restart the agent when done rotating
            }
            
        }
        
        if (IsValueBetween(0.0f, 0.15f, distance) && !_targetReached)
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

    /// <summary>
    /// Rotate Transform until looking at Point
    /// </summary>
    /// <param name="target">target to look at</param>
    private void RotateToPoint(Vector3 target)
    {
        Vector3 targetDirection = target - transform.position;
                
        float SingleStep = _agent.angularSpeed * Time.fixedDeltaTime;
        Vector3 newDirection = Vector3.RotateTowards(transform.forward, targetDirection, SingleStep, 0.0f);
        transform.rotation = Quaternion.LookRotation(newDirection); 
    }
    


    /// <summary>
    /// waits a time of 2f before moving on to the next Waypoint
    /// </summary>
    /// <returns></returns>
    protected virtual IEnumerator WaitBeforeMoving()
    {
        if (currentTarget == Waypoints.Count - 1 || currentTarget == 0)
        {
            _targetReached = false;
            yield return new WaitForSeconds(2f);
        }
        else
        {
            _targetReached = false;
            yield return new WaitForSeconds(2f);
        }
    }


    /// <summary>
    /// sets Player as primary Target and tries to reach him until in Attack Range
    /// </summary>
    private void ChasePlayer()
    {
        transform.LookAt(Player);

        float distance = Vector3.Distance(transform.position, Player.position);

        if (distance >= MinDist)
        {
            _agent.destination = Player.position;

            if (distance <= AttackDist)
            {
                _currentState = EnemyState.Attack;
            }
        }

        transform.position = Vector3.SmoothDamp(transform.position,
            new Vector3(_agent.nextPosition.x, 0, _agent.nextPosition.z), ref velocity, 0.3f);
    }


    /// <summary>
    /// attack the player
    /// </summary>
    public virtual void Attack()
    {
        //depends on how the enemy will attack, use subclass for this
    }

    protected virtual void OnDeath(BasicHealth h)
    {
        
    }
    
    protected virtual void OnDamage(BasicHealth h)
    {
        enemyHealth.UpdateHealthBar(h.Health, h.MaxHealth);
    }

    private void OnDisable()
    {
        _agent.enabled = false;
        _health.OnDeath -= OnDeath;
        _health.OnDamage -= OnDamage;
    }
}