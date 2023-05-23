using Environment;
using UnityEngine;

public class RepairableObject : MonoBehaviour
{
    [SerializeField] private Activatable[] componentBroken;
    
    private void Awake()
    {
        foreach (var component in componentBroken)
        {
            component.IsActivated = false;
        }
    }


    public void Repair()
    {
        foreach (var component in componentBroken)
        {
            component.IsActivated = true;
        }
    }
}
