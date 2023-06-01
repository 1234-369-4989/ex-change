using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Dialog
{
    public class DialogManager : MonoBehaviour
    {
        private Queue<string> _sentences;
        private Dialog _dialog;
        
        [SerializeField] private TextMeshProUGUI nameText;
        [SerializeField] private TextMeshProUGUI dialogText;
        [SerializeField] private Button continueButton;
        [SerializeField] private Animator animator;
        [SerializeField] private CanvasGroup canvasGroup;
        
        [SerializeField] private AudioSource audioSource;
        private static readonly int IsOpen = Animator.StringToHash("IsOpen");
        

        public static DialogManager Instance { get; private set; }

        private void Awake()
        {
            if(Instance == null)
            {
                Instance = this;
            }
            else
            {
                Destroy(gameObject);
            }
            _sentences = new Queue<string>();
        }

        private void Start()
        {
            canvasGroup.gameObject.SetActive(false);
            dialogText.text = "";
            nameText.text = "";
        }

        private void ButtonPressed(InputAction.CallbackContext obj)
        {
            continueButton.onClick.Invoke();
        }

        public void StartDialog(Dialog dialog)
        {
            print("StartDialog with + " + dialog.name);
            _dialog = dialog;
            _sentences.Clear();
            foreach (var sentence in dialog.sentences)
            {
                _sentences.Enqueue(sentence);
            }
            nameText.text = dialog.name;
            canvasGroup.gameObject.SetActive(true);
            DisplayNextSentence();
            if(animator)animator.SetBool(IsOpen, true);
        }

        public void DisplayNextSentence()
        {
            if (_sentences is {Count: 0})
            {
                EndDialog();
                return;
            }

            string sentence = _sentences.Dequeue();
            StopAllCoroutines();
            StartCoroutine(TypeSentence(sentence));
        }
        
        private IEnumerator TypeSentence(string sentence)
        {
            if(audioSource)audioSource.Play();
            dialogText.text = "";
            foreach (var letter in sentence)
            {
                dialogText.text += letter;
                yield return null;
            }
        }

        private void EndDialog()
        {
            if(animator)animator.SetBool(IsOpen, false);
            if (_sentences.Count == 0)
            {
                _dialog.onComplete?.Invoke();
            }
            canvasGroup.gameObject.SetActive(false);
            print("EndDialog");
        }
    }
}
