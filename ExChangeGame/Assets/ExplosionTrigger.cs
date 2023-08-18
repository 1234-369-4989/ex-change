using System.Collections;
using Cinemachine;
using Dialog;
using UnityEngine;

public class ExplosionTrigger : MonoBehaviour
{
    
    [SerializeField]  private DialogSource dialogSource;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private float delay = 1f;
    
    [SerializeField] private float intesity = 4f;
    [SerializeField] private float frequency = 1f;
    [SerializeField] private float time = 1f;
    
    
    [SerializeField] private  NoiseSettings noiseSettings;
    
    private Collider _collider;

    private void Awake()
    {
        _collider = GetComponent<Collider>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
              StartCoroutine(TriggerExplosion());
        }
    }
    
    private IEnumerator TriggerExplosion()
    {
        _collider.enabled = false;
        audioSource.Play();
        CameraShaker.Instance.Shake(intesity, frequency,time);
        yield return new WaitForSeconds(delay);
        DialogManager.Instance.StartDialog(dialogSource.dialog);
    }
}
