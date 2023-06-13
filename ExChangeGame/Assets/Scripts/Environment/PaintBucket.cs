using ExChangeParts;
using UnityEditor;
using UnityEngine;

// when the player touches the paint bucket, the robot should change its color
public class PaintBucket : MonoBehaviour
{
    [SerializeField] private Color color;
    private Renderer _ren;
    private Material _mat;

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
        if(PrefabUtility.IsPartOfPrefabAsset(gameObject)) return;
        if (_ren == null)
            _ren = GetComponent<Renderer>();
        if (_mat == null)
        {
            _mat = Instantiate(_ren.sharedMaterials[1]);
            _mat.color = color;
            _ren.materials = new[] { _ren.sharedMaterials[0], _mat };
        }
        _mat.color = color;
    }
}