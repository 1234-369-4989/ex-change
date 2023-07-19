using Dialog;
using UI;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    [SerializeField] private Canvas[] _uiElements;
    [SerializeField] private ExchangeMenu _exchangeMenu;
    [SerializeField] private PauseMenu _pauseMenu;
    [SerializeField] private DialogManager _dialogueBox;
    
    private int _activeElements;

    private void Awake()
    {
        _exchangeMenu.OnExchangeMenuOpened += OnExchangeMenuOpened;
        _exchangeMenu.OnExchangeMenuClosed += OnExchangeMenuClosed;
        _pauseMenu.OnPause += OnPauseMenuOpened;
        _pauseMenu.OnResume += OnPauseMenuClosed;
        _dialogueBox.OnDialogStarted += OnDialogStarted;
        _dialogueBox.OnDialogEnded += OnDialogEnded;
    }
    
    private void Start()
    {
        _activeElements = 0;
       CheckMouse();
        Debug.Log(Cursor.lockState);
    }

    private void OnDialogEnded()
    {
        _activeElements--;
        CheckMouse();
    }

    private void OnDialogStarted(GameObject o)
    {
        _activeElements++;
        CheckMouse();
    }

    private void OnPauseMenuClosed()
    {
        _activeElements--;
        EnableUI(true);
        CheckMouse();
    }

    private void OnPauseMenuOpened()
    {
        _activeElements++;
        EnableUI(false);
        if(_exchangeMenu.IsOpen) _exchangeMenu.CloseMenu();
        CheckMouse();
    }


    private void OnExchangeMenuClosed()
    {
        _activeElements--;
        EnableUI(true);
        CheckMouse();
    }

    private void OnExchangeMenuOpened()
    {
        _activeElements++;
        EnableUI(false);
        CheckMouse();
    }
    
    private void EnableUI(bool enable)
    {
        foreach (var uiElement in _uiElements)
        {
            uiElement.enabled = enable;
        }
    }

    private void CheckMouse()
    {
        // if Mouse is used and activeElements == 0 -> set Mouse inactive
        // if Mouse is not used and activeElements > 0 -> set Mouse active
        if (_activeElements == 0)
        {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        }
        else
        {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        }
    }
}
    
