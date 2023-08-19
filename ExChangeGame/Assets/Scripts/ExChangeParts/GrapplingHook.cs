using DefaultNamespace;
using Movement;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Serialization;

namespace ExChangeParts
{
    public class GrapplingHook : MonoBehaviour
    {
    
        [Header("References")]
        private MovementRigidbody pm;
        public Transform camera;
        public LayerMask whatIsGrappable;
        [FormerlySerializedAs("lr")] public LineRenderer lr_Left;
        public LineRenderer lr_Right;
        public Rigidbody rb;
        private BasicEnergy _playerEnergy;

        [Header("GrappleValues")]
        public float maxGrappleDistance;
        public float grappleDelayTime;
        public float overshootYAxis;
    
        private Vector3 grapplePoint;
    
        [Header("CooldownValues")]
        public float grapplingCd;
    
        private float grapplingTimer;
    
        [Header("Input")]
        public KeyCode grappleKey = KeyCode.Mouse1;
    
        private bool grappling;
        private bool _isGrappable;
        private bool _freeze;
        private float _speedStorage;
        
        [SerializeField] private InputActionReference grappleAction;

        [Header("Energy & Damage")] [SerializeField]
        private float energyCost = 25f;
        [SerializeField] private int damage = 1;
        
        
        [Header("Audio")]
        [SerializeField] private AudioSource startGrapple;
        
        
        private void OnEnable()
        {
            grappleAction.action.Enable();
            grappleAction.action.performed +=  StartGrapple;
        }

        private void Start()
        {
            pm = GetComponentInParent<MovementRigidbody>();
            _speedStorage = pm.MoveSpeed;
            rb = GetComponentInParent<Rigidbody>();
            _playerEnergy = PlayerInstance.Instance.GetPlayerEnergy();
        }
    
        private void Update()
        {
            if (_freeze)
            {
                pm.MoveSpeed = 0f; //freeze the player for a short time
            }
            else
            {
                pm.MoveSpeed = _speedStorage;
            }

            if (grapplingTimer > 0)
            {
                grapplingTimer -= Time.deltaTime;
            }
            
            if (grappling && _isGrappable)
            {
                _freeze = false;

                var position = transform.position;
                Vector3 lowestPoint = new Vector3(position.x, position.y - 1f, position.z);
                float grapplePointRelativeYPosition = grapplePoint.y - lowestPoint.y;
                float highestPointOnArc = grapplePointRelativeYPosition + overshootYAxis;

                if (grapplePointRelativeYPosition < 0) highestPointOnArc = overshootYAxis;
                JumpToPosition(grapplePoint, highestPointOnArc);
            
                Invoke(nameof(StopGrapple),1f);
            }
    
            if (grapplingTimer > 0) grapplingTimer -= Time.deltaTime;
    
        }

        private void LateUpdate()
        {
            if (grappling)
            {
                lr_Left.SetPosition(0,lr_Left.transform.position);
                lr_Right.SetPosition(0,lr_Right.transform.position);
            }
        }

        private void StartGrapple(InputAction.CallbackContext obj)
        {
            if(UIManager.Instance.HasActiveElements) return;
            if (grapplingTimer > 0) return;
            if (!_playerEnergy.Use(energyCost)) return;
            
            grappling = true;
            _freeze = true;
    
            startGrapple.Play();
            
            RaycastHit hit;
            if (Physics.Raycast(camera.position, camera.forward, out hit, maxGrappleDistance, whatIsGrappable))
            {
                grapplePoint = hit.point;
                _isGrappable = true;
                Debug.Log("Collider hit" , hit.collider);
                MakeDamage(hit.collider);
                Invoke(nameof(ExecuteGrapple), grappleDelayTime);
            }
            else
            {
                grapplePoint = camera.position + camera.forward * maxGrappleDistance;
                _isGrappable = false;
                Debug.Log("No Collider hit");
                Invoke(nameof(StopGrapple), grappleDelayTime);
            }

            lr_Left.enabled = true;
            lr_Left.SetPosition(1, grapplePoint);
            lr_Right.enabled = true;
            lr_Right.SetPosition(1, grapplePoint);

        }

        private void MakeDamage(Collider raycastHit)
        {
            if (raycastHit.TryGetComponent(out BasicHealth health))
            {
                health.Damage(damage);
            }
        }

        private void StopGrapple()
        {
            _freeze = false;
            grappling = false;
            _isGrappable = false;
            
                grapplingTimer = grapplingCd;

            lr_Left.enabled = false;
            lr_Right.enabled = false;
        }

        private void JumpToPosition(Vector3 targetPosition, float trajectoryHeight)
        {
            rb.velocity = CalculateJumpVelocity(transform.position, targetPosition, trajectoryHeight);
        }
        

        private void ExecuteGrapple()
        {
            _freeze = false;
            rb.constraints = RigidbodyConstraints.FreezeRotation;//rotationfreeze is needed, because otherwise when the player hits the wall with its edge uncontrollable spinning ensues

            
            Vector3 lowestPoint = transform.position;
            float grapplePointRelativeYPos = grapplePoint.y - lowestPoint.y;
            float highestPointOnArc = grapplePointRelativeYPos + overshootYAxis;

            if (grapplePointRelativeYPos < 0) highestPointOnArc = overshootYAxis;
            
            JumpToPosition(grapplePoint, highestPointOnArc);

            Invoke(nameof(StopGrapple), 1f);
        }


        private Vector3 CalculateJumpVelocity(Vector3 startpoint, Vector3 endPoint, float trajectoryHeight)
        {
            float gravity = Physics.gravity.y;
            float displacementY = endPoint.y - startpoint.y;
            Vector3 displacementXZ = new Vector3(endPoint.x - startpoint.x, 0f, endPoint.z - startpoint.z);
            
            Vector3 velocityY = Vector3.up * Mathf.Sqrt(-2 * gravity * trajectoryHeight);
            Vector3 velocityXZ = displacementXZ / (Mathf.Sqrt(-2 * trajectoryHeight / gravity)
                                                   + Mathf.Sqrt(2 * (displacementY - trajectoryHeight) / gravity));
            
            return velocityXZ + velocityY;

        }

        private void OnDisable()
        {
            grappleAction.action.Disable();
            grappleAction.action.performed -= StartGrapple;
        }
    }
}
