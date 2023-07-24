using System;
using System.Collections;
using UnityEngine;

namespace Dialog
{
    public class DialogTrigger : DialogSource
    {
        [SerializeField] private bool isDialogActive = true;
        [SerializeField] private float delay = 3;
        [SerializeField] private bool justOnce = true;
        
        bool timerelapsed = false;

        private IEnumerator Start()
        {
            yield return new WaitForSeconds(delay);
            timerelapsed = true;
        }

        private void OnTriggerEnter(Collider other)
        {
            if (!timerelapsed) return;
            if (!isDialogActive)
            {
                dialog.onComplete?.Invoke();
            }
            if (!other.CompareTag("Player")) return;
            if (isDialogActive) StartDialog();
            if(justOnce) isDialogActive = false;
        }
    }
}
