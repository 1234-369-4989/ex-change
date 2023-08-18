using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SoundSetting : MonoBehaviour
{
    [SerializeField]
    private Saving.AudioSaveManager AudioMng;

    public Slider MasterVolumeSlider;
    public Slider MusicVolumeSlider;
    public Slider SFXVolumeSlider;

    private void OnEnable()
    {
        AudioMng.InitAudio();
        getSliderValue();
    }

    private void getSliderValue()
    {
        MasterVolumeSlider.value = Mathf.Clamp(Mathf.Pow(10, Mathf.Clamp(AudioMng.MasterVolumeDB, -80, 0) / 20f), 0, 1);
        MusicVolumeSlider.value = Mathf.Clamp(Mathf.Pow(10, Mathf.Clamp(AudioMng.MusicVolumeDB, -80, 0) / 20f), 0, 1);
        SFXVolumeSlider.value = Mathf.Clamp(Mathf.Pow(10, Mathf.Clamp(AudioMng.SfxVolumeDB, -80, 0) / 20f), 0, 1);
    } 

    public void SetSlidervalue()
    {
        AudioMng.UpdateSound(MasterVolumeSlider.value, MusicVolumeSlider.value, SFXVolumeSlider.value);
    }
}
