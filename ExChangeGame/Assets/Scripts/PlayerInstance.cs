using System.Collections;
using Movement;
using UnityEngine;

[RequireComponent(typeof(BasicHealth))]
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

    private void Start()
    {
        deathEffect.SetActive(false);
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

    private void OnDestroy()
    {
        _playerHealth.OnDeath -= OnPlayerDeath;
        _playerHealth.OnDamage -= OnPlayerDamage;
    }

    public void Respawn()
    {
        _playerHealth.FullHealth();
        playerMovement.enabled = true;
        playerModel.SetActive(true);
    }
}
