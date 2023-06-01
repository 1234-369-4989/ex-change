using UnityEngine;

namespace Environment
{
    // This script is responsible for opening and closing a door when the player enters the trigger
    [RequireComponent(typeof(Collider))]
    [RequireComponent(typeof(Animator))]
    public class Door : Activatable
    {
        private Animator _animator;
        private static readonly int Open = Animator.StringToHash("Open");
    
        [SerializeField] private Light[] lights;
        [SerializeField] private Color activeColor;
        [SerializeField] private Color inactiveColor;
    
        [SerializeField] private bool isActivated;

        private void Start()
        {
            SetActive(isActivated);
        }

        public override bool IsActivated
        {
            get => isActivated;
            set => SetActive(value);
        }

        private void SetActive(bool value)
        {
            isActivated = value;
            foreach (var l in lights)
            {
                l.color = value ? activeColor : inactiveColor;
            }
        }

        private void Awake()
        {
            _animator = GetComponent<Animator>();
        }

        private void OnTriggerEnter(Collider other)
        {
            if (!isActivated) return;
            if (other.CompareTag("Player"))
            {
                _animator.SetBool(Open, true);
            }
        }
    
        private void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                _animator.SetBool(Open, false);
            }
        }
    }
}