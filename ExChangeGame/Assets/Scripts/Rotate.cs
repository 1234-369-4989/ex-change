using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    [SerializeField] private float speed = 1f;
    [SerializeField] private Vector3 axis = Vector3.up;
    [SerializeField] private float angle = 90f;
    
    private float currentAngle = 0f;
    private float direction = 1f;

    private void Start()
    {
        currentAngle = transform.rotation.eulerAngles.y;
    }

    // Update is called once per frame
    void Update()
    {
        currentAngle += speed * direction * Time.deltaTime;
        if (currentAngle >= angle)
        {
            currentAngle = angle;
            direction = -1f;
        }
        else if (currentAngle <= 0f)
        {
            currentAngle = 0f;
            direction = 1f;
        }
        transform.Rotate(axis, speed * direction * Time.deltaTime);
    }
}
