using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Overlay : MonoBehaviour
{
    [SerializeField] private CanvasGroup canvasGroup;
    
    public static Overlay Instance { get; private set; }
    
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
        canvasGroup.gameObject.SetActive(false);
    }
    
    public void FadeIn(float time)
    {
        StartCoroutine(FadeInCoroutine(time));
    }

    private IEnumerator FadeInCoroutine(float time)
    {
        canvasGroup.gameObject.SetActive(true);
        canvasGroup.alpha = 0;
        while (canvasGroup.alpha < 1)
        {
            canvasGroup.alpha += Time.deltaTime / time;
            yield return null;
        }
    }
    
    public void FadeOut(float time)
    {
        StartCoroutine(FadeOutCoroutine(time));
    }
    
    private IEnumerator FadeOutCoroutine(float time)
    {
        canvasGroup.alpha = 1;
        while (canvasGroup.alpha > 0)
        {
            canvasGroup.alpha -= Time.deltaTime / time;
            yield return null;
        }
        canvasGroup.gameObject.SetActive(false);
    }
}
