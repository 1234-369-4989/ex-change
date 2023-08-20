using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class TitleMenu : MonoBehaviour
{
    [SerializeField]
    private Saving.AudioSaveManager AudioMng;

    private void Awake()
    {
        AudioMng.InitAudio();
    }

    public void SceneChange(string SceneName)
    {
        SceneManager.LoadScene(SceneName); 
    }

    public void ExitGame()
    {
        Application.Quit();
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    } 
}
