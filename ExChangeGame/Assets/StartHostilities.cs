using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartHostilities : MonoBehaviour
{
    [SerializeField] private BossBehavior boss;
    private bool _isPlayerDead;

    private void Awake()
    {
        PlayerInstance.OnPlayerDeath += HandlePlayerDeath;
        PlayerInstance.OnPlayerRespawn += HandlePlayerRespawn;
    }

    private void OnTriggerEnter(Collider other)
    {
        StartCoroutine(boss.Taunt());
        boss.Hostile = true;
        gameObject.SetActive(false);
    }
    
    private void HandlePlayerRespawn()
    {
        SetPlayerDead(false);
        gameObject.SetActive(true);
    }

    private void HandlePlayerDeath()
    {
        SetPlayerDead(true);
    }
    
    private void SetPlayerDead(bool b)
    {
        _isPlayerDead = b;
    }
}
