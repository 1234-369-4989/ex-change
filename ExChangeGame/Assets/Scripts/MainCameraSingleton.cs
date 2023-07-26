using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class MainCameraSingleton : MonoBehaviour
{
    public static MainCameraSingleton Instance { get; private set; }
    
    public Camera Camera { get; private set; }
    
    private void Awake()
    {
        if(Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
        Camera = GetComponent<Camera>();
    }
}
