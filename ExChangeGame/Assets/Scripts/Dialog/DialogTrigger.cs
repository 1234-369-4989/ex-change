using UnityEngine;

namespace Dialog
{
    public class DialogTrigger : DialogSource
    {
        [SerializeField] private bool isDialogActive = true;

        private void OnTriggerEnter(Collider other)
        {
            if (!isDialogActive)
            {
                dialog.onComplete?.Invoke();
            }
            if (!other.CompareTag("Player")) return;
            StartDialog();
            isDialogActive = false;
        }
    }
}
