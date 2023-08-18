using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public sealed class DissolveRawImage_UI : MonoBehaviour
{
    [Header("Effect Settings")]
    [SerializeField] float effectDuration = 1f;
    [SerializeField] Ease effectEaseIn = Ease.Linear;
    [SerializeField] Ease effectEaseOut = Ease.Linear;

    [Header("Dissolve Settings")]
    [SerializeField] string dissolveParamName = "_ClipTime";
    [SerializeField] float dissolveParam;

    [SerializeField]
    Material material;

    private Sequence _seq;


    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            DissolveOut();
        }

        if (Input.GetMouseButtonDown(1))
        {
            DissolveIn();
        }
    }

    public void DissolveIn()
    {
        _seq?.Kill();
        _seq = DOTween.Sequence().SetLink(gameObject).SetEase(effectEaseIn);

        material.SetFloat(dissolveParamName, 0);
        _seq.Join(material.DOFloat(dissolveParam, dissolveParamName, effectDuration));

        _seq.Play();
    }

    public void DissolveOut()
    {
        _seq?.Kill();
        _seq = DOTween.Sequence().SetLink(gameObject).SetEase(effectEaseOut);

        material.SetFloat(dissolveParamName, dissolveParam);
        _seq.Join(material.DOFloat(0, dissolveParamName, effectDuration));

        _seq.Play();
    }
}
