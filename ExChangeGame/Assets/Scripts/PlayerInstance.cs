using System.Collections;
using Movement;
using UnityEngine;

[RequireComponent(typeof(BasicHealth))]
public class PlayerInstance : MonoBehaviour
{
    public static PlayerInstance Instance { get; private set; }
    
    private BasicHealth _playerHealth;
    
    [SerializeField] private MovementRigidbody playerMovement;
    [SerializeField] private GameObject playerModel;
    [SerializeField] private AudioSource damageAudioSource;
    [SerializeField] private AudioSource deathAudioSource;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
        _playerHealth = GetComponent<BasicHealth>();
        _playerHealth.OnDeath += OnPlayerDeath;
        _playerHealth.OnDamage += OnPlayerDamage;
    }

    private void OnPlayerDamage(BasicHealth obj)
    {
        damageAudioSource.Play();
    }

    private void OnPlayerDeath(BasicHealth obj)
    {
        Debug.Log("Player died");
        StartCoroutine(DeathCoroutine());
    }
    
    private IEnumerator DeathCoroutine()
    {
        playerMovement.enabled = false;
        playerModel.SetActive(false);
        deathAudioSource.Play();
        yield return new WaitForSeconds(2f);
        gameObject.SetActive(false);
    }

    public BasicHealth GetPlayerHealth()
    {
        return GetComponent<BasicHealth>();
    }

    private void OnDisable()
    {
        _playerHealth.OnDeath -= OnPlayerDeath;
        _playerHealth.OnDamage -= OnPlayerDamage;
    }
}
