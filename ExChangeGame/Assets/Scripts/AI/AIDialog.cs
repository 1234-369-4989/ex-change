using System.Collections.Generic;
using Dialog;
using UnityEngine;


public class AIDialog : MonoBehaviour
{
    [SerializeField] private DialogSource firstDialog;
    [SerializeField] private DialogSource dialog;
    [SerializeField] private GameObject graphics;
    [SerializeField] private bool isMainAI;
    
    private static List<AIDialog> _aiDialogs = new ();

    private void Awake()
    {
        _aiDialogs.Add(this);
    }

    private void Start()
    {
        if(!isMainAI) GetComponent<Collider>().enabled = false;
        dialog.enabled = false;
        graphics.SetActive(false);
    }
    
    public void FirstDialogFinished()
    {
        GetComponent<Collider>().enabled = false;
        foreach (var aiDialog in _aiDialogs)
        {
            aiDialog.dialog.enabled = true;
            aiDialog.graphics.SetActive(true);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!isMainAI || !other.CompareTag("Player")) return;
        graphics.SetActive(true);
        firstDialog.StartDialog();
    }
}
