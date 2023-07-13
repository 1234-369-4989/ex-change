using UnityEngine;

namespace Dialog
{
    public class DialogSource: MonoBehaviour
    {
        [SerializeField] public Dialog dialog;
        
        
        public void StartDialog()
        {
            Debug.Log("StartDialog", this);
            print(DialogManager.Instance);
            print(dialog);
            DialogManager.Instance.StartDialog(dialog);
        }
    }
}