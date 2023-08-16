using UnityEngine;

[RequireComponent(typeof(BasicHealth))]
public class OnBasicHealthDestroy : MonoBehaviour
{
    private BasicHealth _basicHealth;

    private void Awake()
    {
        _basicHealth = GetComponent<BasicHealth>();
    }

    private void OnEnable()
    {
        _basicHealth.OnDeath += DestroyGameObject;
    }

    private void OnDisable()
    {
        _basicHealth.OnDeath -= DestroyGameObject;
    }

    private void DestroyGameObject(BasicHealth basicHealth)
    {
        Destroy(gameObject);
    }
}
