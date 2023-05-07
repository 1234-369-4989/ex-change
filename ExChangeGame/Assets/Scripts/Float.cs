using UnityEngine;

// Makes the object float up and down while rotating
public class Float : MonoBehaviour
{
    [SerializeField] private float heightAmplitude = 0.5f;
    [SerializeField] private float heightFrequency = 1f;
    
    [SerializeField] private float rotationSpeed = 1f;
    
    private Vector3 _startPosition;
    private float _startTime;
    
    private void Start()
    {
        _startPosition = transform.position;
        _startTime = Time.time;
    }
    
    private void Update()
    {
        transform.position = _startPosition + Vector3.up * (Mathf.Sin((Time.time - _startTime) * heightFrequency) * heightAmplitude);
        transform.Rotate(Vector3.up * (rotationSpeed * Time.deltaTime));
    }
}
