using UnityEngine;
using UnityEngine.UI;

public class FloatingEnemyHealth : MonoBehaviour
{
    [SerializeField] private Slider slider; //visible value of health
    private Camera _cam; //Playercamera
    [SerializeField] private Transform target; //position
    [SerializeField] private Vector3 offset;
    
    private Transform _transform;

    private void Start()
    {
        _cam = MainCameraSingleton.Instance.Camera;
        _transform = transform;
    }

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
        _transform.rotation = _cam.transform.rotation;
        _transform.position = target.position + offset;
    }
}