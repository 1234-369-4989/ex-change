using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Serialization;

namespace ExChangeParts
{
    // the welding torch should allow the robot to repair other objects in the world
    public class WeldingTorch : ExchangePart
    {
        [SerializeField] private PlayerInput input;
        [SerializeField] private float repairDistance = 5f;
        [SerializeField] private AudioSource audioSource;
        [SerializeField] private ParticleSystem particleSystem;

        private bool canRepair;
        private readonly RaycastHit[] raycastHits = new RaycastHit[3];
        private Transform _transform;
        private Animator _animator;
        private bool _hasAnimator;
        private bool _hasAudioSource;
        private static readonly int Action1 = Animator.StringToHash("Action");

        private Vector3 rayCastOrigin => transform.position + new Vector3(0, .3f, 0);


        private void Awake()
        {
            _animator = GetComponent<Animator>();
            _hasAnimator = _animator != null;
            _hasAudioSource = audioSource != null;
        }

        private void Start()
        {
            _transform = PlayerInstance.Instance.transform;
        }


        private void OnRepair(InputAction.CallbackContext obj)
        {
            print("Repairing");
            if (_hasAnimator)
            {
                _animator.SetTrigger(Action1);
            }
            if (_hasAudioSource)
            {
                audioSource.Play();
            }
            if (!canRepair) return;
            var ray = new Ray(rayCastOrigin, _transform.forward);
            var size = Physics.RaycastNonAlloc(ray, raycastHits, repairDistance);
            foreach (var hit in raycastHits)
            {
                print("Hit something");
                if (hit.collider == null) continue;
                print("Hit collider");
                Debug.Log("Hit " + hit.collider.name, hit.collider.gameObject);
                var repairable = hit.collider.GetComponent<RepairableObject>();
                
                if (repairable == null) continue;
                print("Hit repairable object");
                repairable.Repair();
                break;
            }
        }

        protected override void OnEquip()
        {
            canRepair = true;
            input.actions["Repair"].performed += OnRepair;
        }

        protected override void OnUnequip()
        {
           canRepair = false; 
           input.actions["Repair"].performed -= OnRepair;
        }
        
        private void OnDestroy()
        {
            if(!input) return;
           input.actions["Repair"].performed -= OnRepair;
        }
        
        public void PlayParticles()
        {
            particleSystem.Play();
        }
    }
}