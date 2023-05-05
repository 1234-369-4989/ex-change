using System;
using System.Collections;
using System.Collections.Generic;
using ExChangeParts;
using StarterAssets;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.TextCore.Text;

namespace ExChangeParts
{
    public class GrapplingHook : ExchangePart
    {
    
        [Header("References")]
        private ThirdPersonController pm;
        public Transform camera;
        public Transform gunTip;
        public LayerMask whatIsGrappable;
        public LineRenderer lr;
        private CharacterController _controller;
        private StarterAssetsInputs _inputs;

        [Header("GrappleValues")]
        public float maxGrappleDistance;
        public float grappleDelayTime;
        public float overshootYAxis;
    
        private Vector3 grapplePoint;
    
        [Header("CooldownValues")]
        public float grapplingCd;
    
        private float grapplingTimer;
    
        [Header("Input")]
        public KeyCode grappleKey = KeyCode.Mouse0;
    
        private bool grappling;
        private bool _isGrappable;
        private bool _freeze;
        private float _speedStorage;


        protected override void OnEquip()
        {
            //engage the Grappling Hook
        }
    
        protected override void OnUnequip()
        {
           //disengange the Grappling Hook
        }
    
        private void Start()
        {
            pm = GetComponent<ThirdPersonController>();
            _speedStorage = pm.MoveSpeed;
            _controller = GetComponent<CharacterController>();
            _inputs = GetComponent<StarterAssetsInputs>();
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
            
            if (grappling && _isGrappable)
            {
                _freeze = false;

                Vector3 lowestPoint = new Vector3(transform.position.x, transform.position.y - 1f, transform.position.z);
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
            Vector3 velocityToSet = CalculateJumpVelocity(transform.position, targetPosition, trajectoryHeight);
            Vector3 targetDirection = Quaternion.Euler(0.0f, CalcualteCurrentRotation(), 0.0f) * Vector3.forward;
            _controller.Move(targetDirection.normalized * (targetDirection.z * Time.deltaTime) + (velocityToSet + targetPosition) * Time.deltaTime);
        }

        private float CalcualteCurrentRotation()
        {
            Vector3 inputDirection = new Vector3(_inputs.move.x, 0.0f, _inputs.move.y).normalized;
            float targetrotation = Mathf.Atan2(inputDirection.x, inputDirection.z) * Mathf.Rad2Deg +
                                   camera.transform.eulerAngles.y;
            return targetrotation;
        }


        private Vector3 CalculateJumpVelocity(Vector3 startpoint, Vector3 endPoint, float trajectoryHeight)
        {
            float gravity = pm.Gravity;
            float displacementY = endPoint.y - startpoint.y;
            Vector3 displacementXZ = new Vector3(endPoint.x - startpoint.x, 0f, endPoint.z - endPoint.z);

            Vector3 velocityY = Vector3.up * Mathf.Sqrt(-2 * gravity * trajectoryHeight);
            Vector3 velocityXZ = displacementXZ / (Mathf.Sqrt(-2 * trajectoryHeight / gravity)
                                                   + Mathf.Sqrt(2 * (displacementY - trajectoryHeight) / gravity));

            return velocityXZ + velocityY;

        }
        
        
        
        
    }


}
