using Dialog;
using UI;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    [SerializeField] private Canvas[] _uiElements;
    [SerializeField] private ExchangeMenu _exchangeMenu;
    [SerializeField] private PauseMenu _pauseMenu;
    [SerializeField] private DialogManager _dialogueBox;
    [field: SerializeField] public GameObject MiniMap { get; private set; }

    [Space(10)] [Header("Cursor")]
    [SerializeField] private Texture2D cursorTextureMain;
    [SerializeField] private Vector2 cursorHotspotMain;
    [SerializeField] private Texture2D cursorTextureCrosshair;
    [SerializeField] private Vector2 cursorHotspotCrosshair;


    private int _activeElements;
    
    public static UIManager Instance { get; private set; }

    private void Awake()
    {
        if (Instance == null) Instance = this;
        else Destroy(gameObject);

        _exchangeMenu.OnExchangeMenuOpened += OnExchangeMenuOpened;
        _exchangeMenu.OnExchangeMenuClosed += OnExchangeMenuClosed;
        _pauseMenu.OnPause += OnPauseMenuOpened;
        _pauseMenu.OnResume += OnPauseMenuClosed;
        DialogManager.OnDialogStarted += OnDialogStarted;
        DialogManager.OnDialogEnded += OnDialogEnded;
        MiniMap.SetActive(false);
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
        if (_exchangeMenu.IsOpen) _exchangeMenu.CloseMenu();
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
            Cursor.SetCursor(cursorTextureCrosshair, cursorHotspotCrosshair, CursorMode.Auto);
        }
        else
        {
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.None;
            Cursor.SetCursor(cursorTextureMain, cursorHotspotMain, CursorMode.Auto);
        }
    }
}