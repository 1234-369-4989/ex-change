using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace Environment
{
    // This script is responsible for opening and closing a door when the player enters the trigger
    [SelectionBase]
    [RequireComponent(typeof(Collider))]
    [RequireComponent(typeof(Animator))]
    public class Door : Activatable
    {
        private Animator _animator;
        [Header("Audio")] [SerializeField] private AudioSource openCloseAudioSource;
        [SerializeField] private AudioSource accessDeniedAudioSource;
        private static readonly int Open = Animator.StringToHash("Open");

        [Header("Colors to change")] [SerializeField]
        private Light[] lights;

        [SerializeField] private Color activeColor;
        [SerializeField] private Color standbyColor;
        [SerializeField] private Color inactiveColor;

        [Header("Materials to change")] [SerializeField]
        private Renderer[] swapRenderers;

        [SerializeField] private Material activeMaterial;
        [SerializeField] private Material standbyMaterial;
        [SerializeField] private Material inactiveMaterial;

        [Header("Renderers to activate")] [SerializeField]
        private Material activeOffMaterial;

        [SerializeField] private Material standbyOffMaterial;
        [SerializeField] private Material inactiveOffMaterial;
        [SerializeField] private Renderer[] activeRenderers;
        [SerializeField] private Renderer[] standbyRenderers;
        [SerializeField] private Renderer[] inactiveRenderers;

        [Header("Other Settings")] [SerializeField]
        private bool isActivated;

        [SerializeField] private Collider _closeCollider;
        [SerializeField] private GameObject minimapIcon;


        private enum State
        {
            Active,
            Standby,
            Inactive
        }

        private void Awake()
        {
            _animator = GetComponent<Animator>();
        }

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
            SwapColors(value ? State.Standby : State.Inactive);
            _closeCollider.enabled = !value;
            var col = GetComponent<CapsuleCollider>();
            // check if player tag is inside of collider
            if (col)
            {
                var player = PlayerInstance.Instance;
                if (player && col.bounds.Contains(player.transform.position))
                {
                    _animator.SetBool(Open, true);
                    openCloseAudioSource.Play();
                    SwapColors(State.Active);
                }
            }

            minimapIcon.SetActive(!value);
        }


        private void OnTriggerEnter(Collider other)
        {
            Debug.Log("Door Trigger Enter");
            if (!other.CompareTag("Player")) return;
            Debug.Log("Door Trigger Enter");
            if (!isActivated)
            {
                accessDeniedAudioSource.Play();
                return;
            }

            Debug.Log("Door Trigger Enter");
            _animator.SetBool(Open, true);
            openCloseAudioSource.Play();
            SwapColors(State.Active);
        }

        private void OnTriggerExit(Collider other)
        {
            if (!isActivated)
            {
                return;
            }

            if (other.CompareTag("Player"))
            {
                _animator.SetBool(Open, false);
                openCloseAudioSource.Play();
                SwapColors(State.Standby);
            }
        }

        private void SwapColors(State state)
        {
            switch (state)
            {
                case State.Active:
                    SwitchColors(activeColor);
                    SwitchMaterials(activeMaterial);
                    ActivateRenderers(state);
                    break;
                case State.Inactive:
                    SwitchColors(inactiveColor);
                    SwitchMaterials(inactiveMaterial);
                    ActivateRenderers(state);
                    break;
                case State.Standby:
                    SwitchColors(standbyColor);
                    SwitchMaterials(standbyMaterial);
                    ActivateRenderers(state);
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(state), state, null);
            }
        }

        private void ActivateRenderers(State state)
        {
            foreach (var r in activeRenderers)
            {
                var mat = r.materials;
                mat[1] = state == State.Active ? activeMaterial : activeOffMaterial;
                r.materials = mat;
            }

            foreach (var r in standbyRenderers)
            {
                var mats = r.materials;
                var newMat = state == State.Standby ? standbyMaterial : standbyOffMaterial;
                if (mats.Length > 1) mats[1] = newMat;
                else mats[0] = newMat;
                r.materials = mats;
            }

            foreach (var r in inactiveRenderers)
            {
                var mat = r.materials;
                mat[1] = state == State.Inactive ? inactiveMaterial : inactiveOffMaterial;
                r.materials = mat;
            }
        }

        private void SwitchMaterials(Material material)
        {
            foreach (var r in swapRenderers)
            {
                var materials = r.materials;
                for (var i = 0; i < materials.Length; i++)
                {
                    if (materials[i].name == activeMaterial.name + " (Instance)"
                        || materials[i].name == standbyMaterial.name + " (Instance)"
                        || materials[i].name == inactiveMaterial.name + " (Instance)")
                    {
                        materials[i] = material;
                    }
                }

                r.materials = materials;
            }
        }

        private void SwitchColors(Color color)
        {
            foreach (var l in lights)
            {
                l.color = color;
            }
        }
    }
}