using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class FloatingEnemyHealth : MonoBehaviour
{

    [SerializeField] private Slider slider; //visible value of health
    [SerializeField] private Camera camera; //Playercamera
    [SerializeField] private Transform target; //position
    [SerializeField] private Vector3 offset;

    /// <summary>
    /// when this update function is called, the value of the slider is changed to the new value
    /// </summary>
    /// <param name="currentValue"></param>
    /// <param name="maxValue"></param>
    public void UpdateHealthBar(float currentValue, float maxValue)
    {
        slider.value = currentValue / maxValue; //need a value between 0 and 1
    }
    /// <summary>
    /// always face the camera
    /// always have the same position above the enemy
    /// </summary>
    void Update()
    {
        transform.rotation = camera.transform.rotation;
        transform.position = target.position + offset;
    }
}
