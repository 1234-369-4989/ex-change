using System;
using System.Collections;
using DefaultNamespace;
using Movement;
using UnityEngine;

[RequireComponent(typeof(BasicHealth))]
[RequireComponent(typeof(BasicEnergy))]
public class PlayerInstance : MonoBehaviour
{
    public static PlayerInstance Instance { get; private set; }
    
    private BasicHealth _playerHealth;
    
    [SerializeField] private MovementRigidbody playerMovement;
    public MovementRigidbody PlayerMovement => playerMovement;
    [SerializeField] private GameObject playerModel;
    [SerializeField] private AudioSource damageAudioSource;
    [SerializeField] private AudioSource deathAudioSource;
    [SerializeField] private GameObject deathEffect;

    public static event Action OnPlayerDeath;
    public static event Action OnPlayerRespawn;
    
    

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
        _playerHealth = GetComponent<BasicHealth>();
        _playerHealth.OnDeath += OnPlayerDeathMethod;
        _playerHealth.OnDamage += OnPlayerDamage;
    }

    private void Start()
    {
        deathEffect.SetActive(false);
    }

    private void OnPlayerDamage(BasicHealth obj)
    {
        damageAudioSource.Play();
    }

    private void OnPlayerDeathMethod(BasicHealth obj)
    {
        Debug.Log("Player died");
        OnPlayerDeath?.Invoke();
        StartCoroutine(DeathCoroutine());
    }
    
    private IEnumerator DeathCoroutine()
    {
        deathEffect.SetActive(true);
        playerMovement.Stop();
        playerMovement.CanMove = false;
        playerModel.SetActive(false);
        deathAudioSource.Play();
        yield return new WaitForSeconds(2f);
        deathEffect.SetActive(false);
        Respawner.Respawn(this);
    }

    public BasicHealth GetPlayerHealth()
    {
        return GetComponent<BasicHealth>();
    }
    
    public BasicEnergy GetPlayerEnergy()
    {
        return GetComponent<BasicEnergy>();
    }

    private void OnDestroy()
    {
        _playerHealth.OnDeath -= OnPlayerDeathMethod;
        _playerHealth.OnDamage -= OnPlayerDamage;
    }

    public void Respawn()
    {
        _playerHealth.FullHealth();
        playerMovement.enabled = true;
        playerModel.SetActive(true);
        OnPlayerRespawn?.Invoke();
    }
}
