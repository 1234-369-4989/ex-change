using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameOver : MonoBehaviour
{
    
    [SerializeField] private GameObject gameOverCanvas;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            gameOverCanvas.SetActive(true);
            Time.timeScale = 0f;
        }
    }
}
