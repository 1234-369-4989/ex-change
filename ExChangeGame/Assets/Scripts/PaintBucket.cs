using ExChangeParts;
using UnityEngine;

// when the player touches the paint bucket, the robot should change its color
public class PaintBucket  : MonoBehaviour
{
    [SerializeField] private Color color;
    private Renderer _ren;

    private void Awake()
    {
        _ren = GetComponent<Renderer>();
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            ExchangeSystem.Instance.ChangeColor(color);
        }
    }

    private void OnValidate()
    {
        if (_ren == null)
            _ren = GetComponent<Renderer>();
        _ren.sharedMaterials[1].color = color;
    }
}