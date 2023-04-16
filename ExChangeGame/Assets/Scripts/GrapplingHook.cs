using System;
using System.Collections;
using System.Collections.Generic;
using StarterAssets;
using UnityEngine;

public class GrapplingHook : MonoBehaviour
{

    [Header("References")]
    private ThirdPersonController pm;
    public Transform camera;
    public Transform gunTip;
    public LayerMask whatIsGrappable;

    [Header("GrappleValues")]
    public float maxGrappleDistance;
    public float grappleDelayTime;

    private Vector3 grapplePoint;

    [Header("CooldownValues")]
    public float grapplingCd;

    private float grapplingTimer;

    [Header("Input")]
    public KeyCode grappleKey;

    private bool grappling;

    private void Start()
    {
        pm = GetComponent<ThirdPersonController>();
    }

    private void Update()
    {
        if(Input.GetKeyDown(grappleKey)) StartGrapple();

        if (grapplingTimer > 0) grapplingTimer -= Time.deltaTime;

    }

    private void StartGrapple()
    {
        if (grapplingTimer > 0) return;

        grappling = true;

        RaycastHit hit;
        if (Physics.Raycast(camera.position, camera.forward, out hit, whatIsGrappable))
        {
            grapplePoint = hit.point;
            
            Invoke(nameof(ExecuteGrapple), grappleDelayTime);
        }
        else
        {
            grapplePoint = camera.position + camera.forward * maxGrappleDistance;
            Invoke(nameof(StopGrapple), grappleDelayTime);
        }


    }

    private void ExecuteGrapple()
    {
        
    }

    private void StopGrapple()
    {
        grappling = false;

        grapplingTimer = grapplingCd;
    }
}
