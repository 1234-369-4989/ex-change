using Movement;
using UnityEngine;

namespace ExChangeParts
{
    public class GrapplingHook : MonoBehaviour
    {
    
        [Header("References")]
        private MovementRigidbody pm;
        public Transform camera;
        public Transform gunTip;
        public LayerMask whatIsGrappable;
        public LineRenderer lr;
        public Rigidbody rb;

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

        private void Start()
        {
            pm = GetComponentInParent<MovementRigidbody>();
            _speedStorage = pm.MoveSpeed;
            rb = GetComponentInParent<Rigidbody>();
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
            
            
            if(Input.GetKeyDown(grappleKey)) StartGrapple();

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
                lr.SetPosition(0,gunTip.position);
            }
        }

        private void StartGrapple()
        {
            if (grapplingTimer > 0) return;
    
            grappling = true;
            _freeze = true;
    
            RaycastHit hit;
            if (Physics.Raycast(camera.position, camera.forward, out hit, maxGrappleDistance, whatIsGrappable))
            {
                grapplePoint = hit.point;
                _isGrappable = true;
                Invoke(nameof(ExecuteGrapple), grappleDelayTime);
            }
            else
            {
                grapplePoint = camera.position + camera.forward * maxGrappleDistance;
                _isGrappable = false;
                Invoke(nameof(StopGrapple), grappleDelayTime);
            }

            lr.enabled = true;
            lr.SetPosition(1, grapplePoint);

        }

        private void StopGrapple()
        {
            _freeze = false;
            grappling = false;
            _isGrappable = false;
            
                grapplingTimer = grapplingCd;

            lr.enabled = false;
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
    }
}
