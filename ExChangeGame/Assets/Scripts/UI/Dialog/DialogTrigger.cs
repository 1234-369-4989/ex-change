using System.Collections;
using UnityEngine;

namespace Dialog
{
    public class DialogTrigger : DialogSource
    {
        [SerializeField] private bool isDialogActive = true;
        [SerializeField] private bool justOnce = true;
        [SerializeField] private float delay = 1f;
        
        private WaitForSeconds _delay;
        
        private Collider _collider;
        private bool _canTrigger;

        private void Awake()
        {
            _collider = GetComponent<Collider>();
            _delay = new WaitForSeconds(delay);
        }

        private void OnEnable()
        {
            _collider.enabled = true;
            StartCoroutine(DelayCoroutine());
        }

        private void OnDisable()
        {
            _collider.enabled = false;
            _canTrigger = false;
            StopAllCoroutines();
        }
        
        private IEnumerator DelayCoroutine()
        {
            yield return _delay;
            _canTrigger = true;
        }

        private void OnTriggerEnter(Collider other)
        {
            if (!_canTrigger) return;
            if (!other.CompareTag("Player")) return;
            if (isDialogActive) StartDialog();
            if(justOnce) isDialogActive = false;
        }
    }
}
