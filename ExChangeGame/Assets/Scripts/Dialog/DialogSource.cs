using UnityEngine;

namespace Dialog
{
    public class DialogSource: MonoBehaviour
    {
        [SerializeField] public Dialog dialog;
        
        private DialogManager dialogManager;
        
        private void Start()
        {
            dialogManager = DialogManager.Instance;
        }
        public void StartDialog()
        {
            dialogManager.StartDialog(dialog);
        }
    }
}