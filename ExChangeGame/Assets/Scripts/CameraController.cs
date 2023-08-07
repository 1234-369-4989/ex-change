using System;
using UnityEngine;
using Cinemachine;
using Dialog;
#if ENABLE_INPUT_SYSTEM 
using UnityEngine.InputSystem;
#endif
using StarterAssets;


public class CameraController : MonoBehaviour
{
    [Header("Cinemachine")]
    [Tooltip("The follow target set in the Cinemachine Virtual Camera that the camera will follow")]
    public Transform CinemachineCameraTarget;

    [Tooltip("How far in degrees can you move the camera up")]
    public float TopClamp = 70.0f;

    [Tooltip("How far in degrees can you move the camera down")]
    public float BottomClamp = -30.0f;

    [Tooltip("Additional degress to override the camera. Useful for fine tuning camera position when locked")]
    public float CameraAngleOverride = 0.0f;

    [Tooltip("For locking the camera position on all axis")]
    public bool LockCameraPosition = false;

    public float Sensitivity = 1.0f;
    
    [Tooltip("Rotation of the camera at the start of the game")]
    [SerializeField] private Vector3 _cameraStartRotation;

    public CinemachineVirtualCamera DefaultCamera;
    public CinemachineVirtualCamera DialogCamera;
    public CinemachineVirtualCamera LowHealthCamera;

    // cinemachine
    private float _cinemachineTargetYaw;
    private float _cinemachineTargetPitch;

#if ENABLE_INPUT_SYSTEM
    private PlayerInput _playerInput;
#endif
    private StarterAssetsInputs _input;

    private const float _threshold = 0.01f;
    
    private Transform _defaultLookAt;

    private bool IsCurrentDeviceMouse
    {
        get
        {
#if ENABLE_INPUT_SYSTEM
                return _playerInput.currentControlScheme == "KeyboardMouse";
#else
            return false;
#endif
        }
    }

    private void Awake()
    {
        _defaultLookAt = DefaultCamera.LookAt;
    }

    private void OnEnable()
    {
        DialogManager.OnDialogStarted += OnDialogStarted;
        DialogManager.OnDialogEnded += OnDialogEnded;
    }

    private void OnDialogStarted(GameObject obj)
    {
        DialogCamera.LookAt = obj.transform;
        DialogCamera.Priority = 100;
    }

    private void OnDialogEnded()
    {
        DialogCamera.Priority = 0;
        DefaultCamera.LookAt = _defaultLookAt;
    }

    

    // Start is called before the first frame update
    void Start()
    {
        CinemachineCameraTarget.rotation = Quaternion.Euler(_cameraStartRotation);
        _cinemachineTargetYaw = CinemachineCameraTarget.rotation.eulerAngles.y;
        _input = GetComponent<StarterAssetsInputs>();
#if ENABLE_INPUT_SYSTEM
        _playerInput = GetComponent<PlayerInput>();
#else
			Debug.LogError( "Starter Assets package is missing dependencies. Please use Tools/Starter Assets/Reinstall Dependencies to fix it");
#endif
        // Start at 180 degrees to avoid camera flipping
        DialogCamera.Priority = 0;
    }

    private void LateUpdate()
    {
        CameraRotation();
    }

    private void CameraRotation()
    {
        
        // if there is an input and camera position is not fixed
        if (_input.look.sqrMagnitude >= _threshold && !LockCameraPosition)
        {
            //Don't multiply mouse input by Time.deltaTime;
            float deltaTimeMultiplier = IsCurrentDeviceMouse ? 1.0f : Time.fixedDeltaTime;

            _cinemachineTargetYaw += _input.look.x * deltaTimeMultiplier * Sensitivity;
            _cinemachineTargetPitch += _input.look.y * deltaTimeMultiplier * Sensitivity;
        }

        // clamp our rotations so our values are limited 360 degrees
        _cinemachineTargetYaw = ClampAngle(_cinemachineTargetYaw, float.MinValue, float.MaxValue);
        _cinemachineTargetPitch = ClampAngle(_cinemachineTargetPitch, BottomClamp, TopClamp);

        // Cinemachine will follow this target
        CinemachineCameraTarget.rotation = Quaternion.Euler(_cinemachineTargetPitch + CameraAngleOverride,
            _cinemachineTargetYaw, 0.0f);
    }

    private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
    {
        if (lfAngle < -360f) lfAngle += 360f;
        if (lfAngle > 360f) lfAngle -= 360f;
        return Mathf.Clamp(lfAngle, lfMin, lfMax);
    }
    
    // private void OnGUI()
    // {
    //     GUI.Label(new Rect(15, 0, 100, 80), "Test Button");
    //     if (GUI.Button(new Rect(0, 40, 100, 30), "Default"))
    //     {
    //         LowHealthCamera.Priority = 5;
    //     }
    //     if (GUI.Button(new Rect(0, 80, 100, 30), "LowHP"))
    //     {
    //         LowHealthCamera.Priority = 15;
    //     }
    //     GUI.Label(new Rect(15, 120, 100, 50), "Sensitivity");
    //     Sensitivity = GUI.HorizontalSlider(new Rect(0, 150, 100, 20), Sensitivity, 0.5f, 3.0f);
    // }

}
