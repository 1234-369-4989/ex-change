using System;
using System.Collections;
using System.Collections.Generic;
using ExChangeParts;
using StarterAssets;
using UnityEngine;

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

        [Header("GrappleValues")]
        public float maxGrappleDistance;
        public float grappleDelayTime;
    
        private Vector3 grapplePoint;
    
        [Header("CooldownValues")]
        public float grapplingCd;
    
        private float grapplingTimer;
    
        [Header("Input")]
        public KeyCode grappleKey = KeyCode.Mouse0;
    
        private bool grappling;
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
        }
    
        private void Update()
        {
            if (_freeze)
            {
                pm.MoveSpeed = 0f;
            }
            else
            {
                pm.MoveSpeed = _speedStorage;
            }
            if(Input.GetKeyDown(grappleKey)) StartGrapple();
    
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
                
                Invoke(nameof(ExecuteGrapple), grappleDelayTime);
            }
            else
            {
                Debug.Log("Not grappable");
                grapplePoint = camera.position + camera.forward * maxGrappleDistance;
                Invoke(nameof(StopGrapple), grappleDelayTime);
            }

            lr.enabled = true;
            lr.SetPosition(1, grapplePoint);

        }
    
        private void ExecuteGrapple()
        {
            _freeze = false;
        }
    
        private void StopGrapple()
        {
            _freeze = false;
            grappling = false;
    
            grapplingTimer = grapplingCd;

            lr.enabled = false;
        }

        private void JumpToPosition(Vector3 targetPosition, float trajectoryHeight)
        {
            
        }


        private Vector3 CalculateJumpVelocity(Vector3 startpoint, Vector3 endPoint, float trajectoryHeight)
        {
            float gravity = Physics.gravity.y;
            float displacementY = endPoint.y - startpoint.y;
            Vector3 displacementXZ = new Vector3(endPoint.x - startpoint.x, 0f, endPoint.z - endPoint.z);

            Vector3 velocityY = Vector3.up * Mathf.Sqrt(-2 * gravity * trajectoryHeight);
            Vector3 velocityXZ = displacementXZ / (Mathf.Sqrt(-2 * trajectoryHeight / gravity) + Mathf.Sqrt(2 * (displacementY - trajectoryHeight) / gravity));

            return velocityXZ + velocityY;

        }
        
        
        
        
    }


}
