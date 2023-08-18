using UnityEngine;
using UnityEngine.Audio;

namespace Saving
{
    public class AudioSaveManager : MonoBehaviour
    {
        [SerializeField] private AudioMixer mixer;
        private float _masterVolumeDB;
        private float _musicVolumeDB;
        private float _sfxVolumeDB;
        private float _uiVolumeDB;

        public float MasterVolumeDB => _masterVolumeDB;
        public float MusicVolumeDB => _musicVolumeDB;
        public float SfxVolumeDB => _sfxVolumeDB;

        private void Start()
        {
            SetAudio();
        }

        public void InitAudio()
        {
            _masterVolumeDB = PlayerPrefs.GetFloat("Master", 1);
            _musicVolumeDB = PlayerPrefs.GetFloat("Music", 1);
            _sfxVolumeDB = PlayerPrefs.GetFloat("Sound", 1);
            _uiVolumeDB = PlayerPrefs.GetFloat("UI", 1);
            SetAudio();
        }

        private void GetAudio()
        {
            mixer.GetFloat("Master", out _masterVolumeDB);
            mixer.GetFloat("Music", out _musicVolumeDB);
            mixer.GetFloat("Sound", out _sfxVolumeDB);
            mixer.GetFloat("UI", out _uiVolumeDB);
        }

        private void SetAudio()
        {
            mixer.SetFloat("Master", _masterVolumeDB);
            mixer.SetFloat("Music", _musicVolumeDB);
            mixer.SetFloat("Sound", _sfxVolumeDB);
            mixer.SetFloat("UI", _uiVolumeDB);
        }

        private void SaveAudio()
        {
            GetAudio();
            PlayerPrefs.SetFloat("Master", _masterVolumeDB);
            PlayerPrefs.SetFloat("Music", _musicVolumeDB);
            PlayerPrefs.SetFloat("Sound", _sfxVolumeDB);
            PlayerPrefs.SetFloat("UI", _uiVolumeDB);
        }

        /// <summary>
        /// This method should be called when the player changes the volume in the settings menu
        /// </summary>
        /// <param name="masterVolume"></param>
        /// <param name="musicVolume"></param>
        /// <param name="sfxVolume"></param>
        public void UpdateSound(float masterVolume, float musicVolume, float sfxVolume)
        {
            _masterVolumeDB = Mathf.Log10(masterVolume) * 20;
            _musicVolumeDB = Mathf.Log10(musicVolume) * 20;
            _sfxVolumeDB = Mathf.Log10(sfxVolume) * 20;
            _uiVolumeDB = Mathf.Log10(sfxVolume) * 20;
            SetAudio();
            SaveAudio();
        }
    }
}