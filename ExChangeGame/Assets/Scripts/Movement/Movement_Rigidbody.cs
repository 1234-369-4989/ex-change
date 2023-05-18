using System;
using System.Collections;
using System.Collections.Generic;
using ExChangeParts;
using StarterAssets;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.TextCore.Text;

#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif

#if ENABLE_INPUT_SYSTEM
[RequireComponent(typeof(PlayerInput))]
#endif    

public class Movement_Rigidbody : MonoBehaviour
{
    [Header("Player")]
    [Tooltip("Move speed of the character")]
    [SerializeField] private float defaultMoveSpeed = 2.0f;
    public float _moveSpeed = 2.0f;
    
    [Tooltip("Sprint speed of the character in m/s")]
    [SerializeField] private float defaultSprintSpeed = 5.335f;
    private float _sprintSpeed = 5.335f;
    
    [Tooltip("How fast the character turns to face movement direction")]
    [Range(0.0f, 0.3f)]
    [SerializeField] private float rotationSmoothTime = 0.12f;


    [Space(10)] [Tooltip("The Height the player can jump")]
    private bool _canJump;
    //TODO handle canFloat
    private bool _canFloat;
    private float _jumpHeight;
    
    [Space(10)]
    [Tooltip("Time required to pass before being able to jump again. Set to 0f to instantly jump again")]
    [SerializeField] private float jumpTimeout = 0.50f;

    private ExchangeSystem _exchangeSystem;

    [Header("Player Grounded")] [Tooltip("If the cahracter is grounded or not.")] [SerializeField]
    private bool _isGrounded = true;
    
    [Tooltip("Useful for rough ground")]
    [SerializeField] private float groundedOffset = -0.14f;
    
    [Tooltip("The radius of the grounded check. Should match the radius of the CharacterController")]
    [SerializeField] private float groundedRadius = 0.28f;

    [Tooltip("What layers the character uses as ground")]
    [SerializeField] private LayerMask groundLayers;
    
    // player
    private float _speed;
    private float _animationBlend;
    private float _targetRotation;
    private float _rotationVelocity;
    private float _verticalVelocity;
    private float _terminalVelocity = 53.0f;

    // timeout deltatime
    private float _jumpTimeoutDelta;
    private float _fallTimeoutDelta;
    
    // animation IDs
    private int _animIDSpeed;
    private int _animIDGrounded;
    private int _animIDJump;
    private int _animIDFreeFall;
    private int _animIDMotionSpeed;
    
    //PlayerCameraRoot
    public GameObject PlayerCameraRoot;
    private List<Vector3> _playerroute;
    private float _distancePlayerToCameraRoot;

#if ENABLE_INPUT_SYSTEM
        private PlayerInput _playerInput;
    #endif

    private Animator _animator;
    private Rigidbody _playerBody;
    private StarterAssetsInputs _input;
    private GameObject _mainCamera;

    private bool _hasAnimator;

    /// <summary>
    /// Method for checking if the current Inputdevice is Mouse and Keyboard
    /// </summary>
    private bool IsCurrentDeviceMouse
    {
        get
        {
            #if ENABLE_INPUT_SYSTEM
                return _playerInput.currentControlScheme == "KeyboardMouse";
            #else
                return false;
            #endif
        }
        
    }


    private void Awake()
    {
        _playerroute = new List<Vector3>();
        _distancePlayerToCameraRoot = Vector3.Distance(transform.position, PlayerCameraRoot.transform.position);
        
        //get a reference for the main camera
        if (_mainCamera == null)
        {
            _mainCamera = GameObject.FindGameObjectWithTag("MainCamera");
        }
        _exchangeSystem = GetComponent<ExchangeSystem>();
    }


    // Start is called before the first frame update
    void Start()
    {
        _hasAnimator = TryGetComponent(out _animator);
        _playerBody = GetComponent<Rigidbody>();
        _input = GetComponent<StarterAssetsInputs>();

#if ENABLE_INPUT_SYSTEM
        _playerInput = GetComponent<PlayerInput>();
        #else
        Debug.LogError( "Starter Assets package is missing dependencies. Pleas
        #endif

        AssignAnimationIDs();
        
        // reset our timeouts on start
        _jumpTimeoutDelta = jumpTimeout;

        _moveSpeed = defaultMoveSpeed;
        _sprintSpeed = defaultSprintSpeed;
        _canJump = true;
        _jumpHeight = 2;
            
       _exchangeSystem.OnMovementChanged += OnMovementChanged;

    }
    
    // Update is called once per frame
    void Update()
    {
        _hasAnimator = TryGetComponent(out _animator);
    }

    //Is called after a set time, needed for Physics Movement
    private void FixedUpdate()
    {
        Jump();
        GroundedCheck();
        Move();
        _playerroute.Add(transform.position + new Vector3(0.0f, _distancePlayerToCameraRoot, 0.0f));

        if (_playerroute.Count > 1)
        {
            _playerroute.RemoveAt(0);
            PlayerCameraRoot.transform.position = _playerroute[0];
        }
    }
    
    

    //Method for Calculating Movement and Applying it
    private void Move()
    {
        float targetSpeed = _input.sprint ? _sprintSpeed : _moveSpeed; //set current movementspeed
        float inputMagnitude = _input.analogMovement ? _input.move.magnitude : 1f; // how strong is the input

        if (_input.move == Vector2.zero) targetSpeed = 0.0f;

        Vector3 targetInput = new Vector3(_input.move.x, 0.0f, _input.move.y).normalized; //get current input values

        if (_input.move != Vector2.zero)
        {
            //Calculate Rotation of Player Model
            _targetRotation = Mathf.Atan2(targetInput.x, targetInput.z) * Mathf.Rad2Deg + _mainCamera.transform.eulerAngles.y;

            float rotation = Mathf.SmoothDampAngle(transform.eulerAngles.y, _targetRotation, ref _rotationVelocity,
                rotationSmoothTime);
            
            
            _playerBody.MoveRotation(Quaternion.Euler(0.0f, rotation, 0.0f));
        }
        
        Vector3 targetDirection = Quaternion.Euler(0.0f, _targetRotation, 0.0f) * Vector3.forward;//Calculate Movementdirection via Rotation
        
        _playerBody.MovePosition(transform.position + targetDirection * (Time.fixedDeltaTime * targetSpeed));//Move Towards next position



        if (_hasAnimator)
        {
            _animator.SetFloat(_animIDSpeed, _animationBlend);
            _animator.SetFloat(_animIDMotionSpeed, inputMagnitude);
        }

    }

    //Method for Jumping
    private void Jump()
    {
        if (_isGrounded)
        {
            if (_hasAnimator)
            {
                _animator.SetBool(_animIDJump, false);
                _animator.SetBool(_animIDFreeFall, false);
            }
            //Jumping
             if (_input.jump && _canJump && _jumpTimeoutDelta <= 0.0f)
             {
                 _playerBody.AddForce(new Vector3(0,_jumpHeight,0), ForceMode.Impulse);//apply an upwards force to the rigidbody
                 if (_hasAnimator)
                 {
                    _animator.SetBool(_animIDJump, true);
                 }
             }
             
             if (_jumpTimeoutDelta >= 0.0f)
             {
                 _jumpTimeoutDelta -= Time.deltaTime;
             }
        }//end if(_isGrounded)
        else
        {
            _jumpTimeoutDelta = jumpTimeout;

            if (_fallTimeoutDelta >= 0.0f)
            {
                _fallTimeoutDelta -= Time.deltaTime;
                _input.jump = false;
            }
            else
            {
                if (_hasAnimator)
                {
                    _animator.SetBool(_animIDFreeFall, true);
                }

                _input.jump = false; //when not grounded, do not jump
            }
        }
    }
    
    //AnimationID assingments
    private void AssignAnimationIDs()
    {
        _animIDSpeed = Animator.StringToHash("Speed");
        _animIDGrounded = Animator.StringToHash("Grounded");
        _animIDJump = Animator.StringToHash("Jump");
        _animIDFreeFall = Animator.StringToHash("FreeFall");
        _animIDMotionSpeed = Animator.StringToHash("MotionSpeed");
    }

    //check if the player is currently grounded
    private void GroundedCheck()
    {
        var pos = transform.position;
        //set sphere position, with offset
        Vector3 spherePosition = new Vector3(pos.x, pos.y - groundedOffset, pos.z);
        _isGrounded = Physics.CheckSphere(spherePosition, groundedRadius, groundLayers, QueryTriggerInteraction.Ignore);

        if (_hasAnimator)
        {
            _animator.SetBool(_animIDGrounded, _isGrounded);
        }
    }
    private void OnDestroy()
    {
       _exchangeSystem.OnMovementChanged -= OnMovementChanged;
    }
    
    //get Movement values according to parts exchanged
    private void OnMovementChanged(MovementVariables movementvariables)
    {
        _moveSpeed = movementvariables.MoveSpeed ?? defaultMoveSpeed;
        _sprintSpeed = movementvariables.SprintSpeed ?? defaultSprintSpeed;
        _canJump = movementvariables.CanJump;
        _canFloat = movementvariables.CanFloat;
        _jumpHeight = movementvariables.JumpHeight ?? 0;
    }
}
