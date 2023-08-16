using UnityEngine;

public class RotateToPlayer : MonoBehaviour
{
    [SerializeField] private float xLimit;
    [SerializeField] private float rotationSpeed;
    
    private Transform _player;

    private void Start()
    {
        _player = PlayerInstance.Instance.transform;
    }

    private void Update()
    {
        var targetRotation = Quaternion.LookRotation(_player.position - transform.position);
        var euler = targetRotation.eulerAngles;
        euler.x = Mathf.Clamp(euler.x, -xLimit, xLimit);
         targetRotation.eulerAngles = euler;
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
    }
}
