using System.Collections;
using Cinemachine;
using UnityEngine;

public class CameraShaker : MonoBehaviour
{
    
    private CinemachineVirtualCamera _virtualCamera;
    private float _intensity = 1f;
    private float _frequency = 1f;
   private float _timer;
    
    private CinemachineBasicMultiChannelPerlin _perlin;
    
    private float _startingIntensity;
    private float _startingAmplitudeGain;
    private NoiseSettings _startNoiseSettings;

    [SerializeField] private NoiseSettings sDProfile;
    
    public static CameraShaker Instance { get; private set; }

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
        
        _virtualCamera = GetComponent<CinemachineVirtualCamera>();
        _perlin = _virtualCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        _startingIntensity = _perlin.m_AmplitudeGain;
        _startingAmplitudeGain = _perlin.m_AmplitudeGain;
        _startNoiseSettings = _perlin.m_NoiseProfile;
    }

    public void Shake(float intensity, float frequency, float time)
   {
       _intensity = intensity;
         _frequency = frequency;
       _timer = time;
       StartCoroutine(CameraShake());
   }

   private IEnumerator CameraShake()
   {
       while (_timer > 0)
       {
           _perlin.m_AmplitudeGain = _intensity;
           _perlin.m_FrequencyGain = _frequency;
           _perlin.m_NoiseProfile = sDProfile;
           _timer -= Time.deltaTime;
           yield return null;
       }
         _perlin.m_AmplitudeGain = _startingAmplitudeGain;
         _perlin.m_FrequencyGain = _startingIntensity;
            _perlin.m_NoiseProfile = _startNoiseSettings;
   }
}
