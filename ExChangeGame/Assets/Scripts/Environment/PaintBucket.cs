using ExChangeParts;
using UnityEditor;
using UnityEngine;

// when the player touches the paint bucket, the robot should change its color
public class PaintBucket : MonoBehaviour
{
    [SerializeField] private Color color;
    [SerializeField] private new Renderer renderer;
    private Material _mat;

    private void Awake()
    {
        renderer = GetComponent<Renderer>();
    }

    private void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            ExchangeSystem.Instance.ChangeColor(color);
        }
    }

    private void OnValidate()
    {
        if(PrefabUtility.IsPartOfPrefabAsset(gameObject)) return;
        if (renderer == null)
            renderer = GetComponent<Renderer>();
        if (_mat == null)
        {
            if(renderer.sharedMaterial == null) return;
            _mat = Instantiate(renderer.sharedMaterial);
            _mat.color = color;
            renderer.material = _mat;
        }
        _mat.color = color;
    }
}