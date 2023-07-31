using System.Collections.Generic;
using ExChangeParts;
using StarterAssets;
using UnityEngine;
using UnityEngine.InputSystem;

#if ENABLE_INPUT_SYSTEM
namespace Movement
{
    [RequireComponent(typeof(PlayerInput))]
#endif

    [SelectionBase]
    public class MovementRigidbody : MonoBehaviour
    {
        [Header("Player")]
        [Header("Movement Settings")]
        [Tooltip("Move speed of the character")]
        [SerializeField] private float defaultMoveSpeed = 2.0f;
        private float _moveSpeed = 2.0f;

        public float MoveSpeed
        {
            get => _moveSpeed;
            set => _moveSpeed = value;
        }

        [Tooltip("Sprint speed of the character in m/s")]
        [SerializeField] private float defaultSprintSpeed = 5.335f;
        private float _sprintSpeed = 5.335f;

        [Tooltip("How fast the character turns to face movement direction")] 
        [SerializeField][Range(0.0f, 0.3f)] private float rotationSmoothTime = 0.12f;

        [Tooltip("Acceleration and deceleration")]
        [SerializeField] private float speedChangeRate = 10.0f;
        
        [Space(10)]
        [Header("Jump Settings")]
        [Tooltip("Time required to pass before being able to jump again. Set to 0f to instantly jump again")]
        [SerializeField] private float jumpTimeout = 0.50f;

        [Space(10)]
        [Header("Floating Settings")]
        [Tooltip("Maximum height to which can be floated")]
        [SerializeField] private float floatHeight = 1f;
        [SerializeField] private float floatStrength;
        [SerializeField] private float floatFallDecelaration = 1.1f;
        [SerializeField] private float floatFallDecelarationHeight = .5f;
        [SerializeField] private ForceMode floatForceMode;

        [Space(10)]
        [Header("Player Grounded")]
        [Tooltip("If the cahracter is grounded or not.")]
        [SerializeField] private bool isGrounded = true;

        [Tooltip("Useful for rough ground")]
        [SerializeField] private float groundedOffset = -0.14f;

        [Tooltip("The radius of the grounded check. Should match the radius of the CharacterController")]
        [SerializeField] private float groundedRadius = 0.28f;

        [Tooltip("What layers the character uses as ground")]
        [SerializeField] private LayerMask groundLayers;
        
        [Space(10)]
        [Header("Player Camera")]
        //PlayerCameraRoot
        [SerializeField] private GameObject playerCameraRoot;
        
        [Space(10)]
        [Header("Sound")]
        [SerializeField] private AudioSource jumpSound;
        [SerializeField] private AudioSource landSound;   
        [SerializeField] private AudioSource floatSound;
        [SerializeField] private AudioSource sprintSound;
        
        [Header("VFX")]
        [SerializeField] private ParticleSystem jumpVFX;
        // [SerializeField] private ParticleSystem landVFX;
        [SerializeField] private ParticleSystem floatVFX;
        [SerializeField] private ParticleSystem sprintVFX;
        
        private float _distancePlayerToCameraRoot;

        // player
        private float _speed;
        private float _lastSpeed;
        private float _floatStartHeight;
        private float _animationBlend;
        private float _targetRotation;
        private float _rotationVelocity;
        private float _verticalVelocity;
        private bool _canJump;
        private bool _canFloat;
        private float _jumpHeight;
        private float _currentHeight;
        private bool _isJumping;
        public bool CanMove { get; set; }

        // timeout deltatime
        private float _jumpTimeoutDelta;
        private float _fallTimeoutDelta;

        private ExchangeSystem _exchangeSystem;
        private List<Vector3> _playerroute;
        private PlayerInput _playerInput;
        private Rigidbody _playerBody;
        private StarterAssetsInputs _input;
        private GameObject _mainCamera;
        
        private void Awake()
        {
            _playerroute = new List<Vector3>();
            _distancePlayerToCameraRoot = Vector3.Distance(transform.position, playerCameraRoot.transform.position);
            _playerBody = GetComponent<Rigidbody>();
            _input = GetComponent<StarterAssetsInputs>();
            _playerInput = GetComponent<PlayerInput>();
            
            _playerInput.actions["Jump"].performed += JumpPerformed;

            //get a reference for the main camera
            if (_mainCamera == null)
            {
                _mainCamera = GameObject.FindGameObjectWithTag("MainCamera");
            }

            _exchangeSystem = GetComponent<ExchangeSystem>();
        }

        private void JumpPerformed(InputAction.CallbackContext obj)
        {
              _isJumping = !_isJumping;
        }


        // Start is called before the first frame update
        void Start()
        {

            // reset our timeouts on start
            _jumpTimeoutDelta = jumpTimeout;

            _moveSpeed = defaultMoveSpeed;
            _sprintSpeed = defaultSprintSpeed;
            _canJump = false;
            _jumpHeight = 2;

            _exchangeSystem.OnMovementChanged += OnMovementChanged;
            CanMove = true;
        }

        //Is called after a set time, needed for Physics Movement
        private void FixedUpdate()
        {
            if (_canFloat) HandleFloat();
            else Jump();
            GroundedCheck();
            if(CanMove) Move();
            _playerroute.Add(transform.position + new Vector3(0.0f, _distancePlayerToCameraRoot, 0.0f));

            if (_playerroute.Count > 1)
            {
                _playerroute.RemoveAt(0);
                playerCameraRoot.transform.position = _playerroute[0];
            }
        }


        private bool _sprinting;
        //Method for Calculating Movement and Applying it
        private void Move()
        {
            float targetSpeed = _input.sprint ? _sprintSpeed : _moveSpeed; //set current movementspeed
            if (_input.sprint && !_sprinting)
            {
                sprintSound.Play();
                sprintVFX.Play();
                _sprinting = true;
            }
            else if (!_input.sprint && _sprinting)
            {
                sprintSound.Stop();
                sprintVFX.Stop();
                _sprinting = false;
            }

            if (_input.move == Vector2.zero) targetSpeed = 0.0f;

            float speedOffset = 0.1f;
            float inputMagnitude = _input.analogMovement ? _input.move.magnitude : 1f;

            // accelerate or decelerate to target speed
            if (_lastSpeed < targetSpeed - speedOffset ||
                _lastSpeed > targetSpeed + speedOffset)
            {
                // creates curved result rather than a linear one giving a more organic speed change
                // note T in Lerp is clamped, so we don't need to clamp our speed
                _speed = Mathf.Lerp(_lastSpeed, targetSpeed * inputMagnitude,
                    Time.fixedDeltaTime * speedChangeRate);

                // round speed to 3 decimal places
                _speed = Mathf.Round(_speed * 1000f) / 1000f;
            }
            else
            {
                _speed = targetSpeed;
            }

            _lastSpeed = _speed;

            Vector3 targetInput = new Vector3(_input.move.x, 0.0f, _input.move.y).normalized; //get current input values

            if (_input.move != Vector2.zero)
            {
                //Calculate Rotation of Player Model
                _targetRotation = Mathf.Atan2(targetInput.x, targetInput.z) * Mathf.Rad2Deg +
                                  _mainCamera.transform.eulerAngles.y;

                float rotation = Mathf.SmoothDampAngle(transform.eulerAngles.y, _targetRotation, ref _rotationVelocity,
                    rotationSmoothTime);


                _playerBody.MoveRotation(Quaternion.Euler(0.0f, rotation, 0.0f));
            }

            Vector3 targetDirection =
                Quaternion.Euler(0.0f, _targetRotation, 0.0f) *
                Vector3.forward; //Calculate Movementdirection via Rotation

            var position = transform.position;

            _playerBody.MovePosition(position + targetDirection.normalized * (_speed * Time.fixedDeltaTime) +
                                     new Vector3(0.0f, _verticalVelocity, 0.0f) * Time.fixedDeltaTime);
        }

        //Method for Jumping
        private void Jump()
        {
            if (isGrounded)
            {
                //Jumping
                if (_input.jump && _canJump && _jumpTimeoutDelta <= 0.0f)
                {
                    _playerBody.AddForce(new Vector3(0, _jumpHeight, 0),
                        ForceMode.Impulse); //apply an upwards force to the rigidbody
                    jumpSound.Play();
                    jumpVFX.Play();
                }
                else
                {
                    _input.jump = false;
                }

                if (_jumpTimeoutDelta >= 0.0f)
                {
                    _jumpTimeoutDelta -= Time.fixedDeltaTime;
                }
            } //end if(_isGrounded)
            else
            {
                _jumpTimeoutDelta = jumpTimeout;

                if (_fallTimeoutDelta >= 0.0f)
                {
                    _fallTimeoutDelta -= Time.fixedDeltaTime;
                    _input.jump = false;
                }
                else
                {
                    _input.jump = false; //when not grounded, do not jump
                }
            }
        }

        private bool _isFloating;
        private void HandleFloat()
        {
            // raycast to ground
            Ray ray = new Ray(transform.position, Vector3.down);
            if (Physics.Raycast(ray, out var hit))
            {
                _currentHeight = hit.distance;
            }

            // jump
            if (_isJumping && _canJump)
            {
                if(!_isFloating)
                {
                    floatSound.Play();
                    floatVFX.Play();
                    _isFloating = true;
                }
                var strength = floatStrength;
                strength *= Time.fixedDeltaTime;

                // upwards force
                var distanceFromTop = floatHeight - _currentHeight;
                
                if(_playerBody.velocity.y < 0 && distanceFromTop > floatHeight * floatFallDecelarationHeight)
                    strength *= floatFallDecelaration;
                
                if(distanceFromTop >= 0)
                    _playerBody.AddForce(new Vector3(0, strength, 0), floatForceMode);
                else
                {
                    strength -= 0.1f * -distanceFromTop * 10;
                    _playerBody.AddForce(new Vector3(0, strength, 0), floatForceMode);
                }
            }
            else
            {
                if (_isFloating)
                {
                    floatSound.Stop();
                    floatVFX.Stop();
                    _isFloating = false;
                }
            }
        }

        //check if the player is currently grounded
        private void GroundedCheck()
        {
            var wasGrounded = isGrounded;
            var pos = transform.position;
            //set sphere position, with offset
            Vector3 spherePosition = new Vector3(pos.x, pos.y - groundedOffset, pos.z);
            isGrounded = Physics.CheckSphere(spherePosition, groundedRadius, groundLayers,
                QueryTriggerInteraction.Ignore);
            if (!wasGrounded && isGrounded)
                Land();
        }

        private void Land()
        {
            //TODO Animation
            //landVFX.Play();
            landSound.Play();
        }

        private void OnDestroy()
        {
            _playerInput.actions["Jump"].performed -= JumpPerformed;
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

        public void Stop()
        {
            _playerBody.velocity = Vector3.zero;
            _playerBody.angularVelocity = Vector3.zero;
            _input.move = Vector2.zero;
            _input.jump = false;
            _input.sprint = false;
            _input.analogMovement = false;
            _input.look = Vector2.zero;
            _lastSpeed = 0;
            jumpSound.Stop();
            floatSound.Stop();
            sprintSound.Stop();
            landSound.Stop();
            sprintVFX.Stop();
            floatVFX.Stop();
            jumpVFX.Stop();
            //TODO: landVFX.Stop();
        }
    }
}