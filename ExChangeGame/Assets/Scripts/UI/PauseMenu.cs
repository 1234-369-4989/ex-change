
using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class PauseMenu : MonoBehaviour
{
    [SerializeField] private InputActionReference pauseAction;
    [SerializeField]
    GameObject pauseMenu;
    [SerializeField]
    GameObject optionMenu;
    
    
    public event Action OnPause;
    public event Action OnResume;


    private void Awake()
    {
        pauseAction.action.performed += SwitchPause;
    }

    private void SwitchPause(InputAction.CallbackContext callbackContext)
    {
        if (pauseMenu.activeSelf || optionMenu.activeSelf)
        {
            Time.timeScale = 1f;
            pauseMenu.SetActive(false);
            optionMenu.SetActive(false);
            OnResume?.Invoke();
        }
        else
        {
            Time.timeScale = 0f;
            pauseMenu.SetActive(true);
            OnPause?.Invoke();
        }
    }
    
    
    public void EndGame()
    {
        Application.Quit();
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    }

    private void OnDestroy()
    {
        pauseAction.action.performed -= SwitchPause;
    }
}
