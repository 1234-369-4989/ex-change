using System;
using UnityEngine;

namespace Environment
{
    // This script is responsible for opening and closing a door when the player enters the trigger
    [SelectionBase]
    [RequireComponent(typeof(Collider))]
    [RequireComponent(typeof(Animator))]
    [RequireComponent(typeof(AudioSource))]
    public class Door : Activatable
    {
        private Animator _animator;
        private AudioSource _audioSource;
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
        [SerializeField] private Collider _openCollider;


        private enum State
        {
            Active,
            Standby,
            Inactive
        }

        private void Awake()
        {
            _animator = GetComponent<Animator>();
            _audioSource = GetComponent<AudioSource>();
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
            _openCollider.enabled = value;
            _closeCollider.enabled = !value;
        }


        private void OnTriggerEnter(Collider other)
        {
            if (!isActivated) return;
            if (other.CompareTag("Player"))
            {
                _animator.SetBool(Open, true);
                _audioSource.Play();
                SwapColors(State.Active);
            }
        }

        private void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                _animator.SetBool(Open, false);
                _audioSource.Play();
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