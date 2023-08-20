using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public sealed class DissolvePixel : MonoBehaviour
{
    [Header("Effect Settings")]
    [SerializeField] float effectDuration = 1f;
    [SerializeField] Ease effectEaseIn = Ease.Linear;
    [SerializeField] Ease effectEaseOut = Ease.Linear;

    [Header("Dissolve Settings")]
    [SerializeField] string dissolveParamName = "_ClipTime";
    [SerializeField] float dissolveParam;

    [Header("Emission Settings")]
    [SerializeField] string emissionParamName = "_EmissionPower";
    [SerializeField] float emissionParam;

    [SerializeField]
    List<Material> materials = new List<Material>();

    private Sequence _seq;

    void Start()
    {
        GetMaterialsRecursively(transform);
    }

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

        foreach (Material m in materials)
        {
            m.SetFloat(dissolveParamName, 0);
            m.SetFloat(emissionParamName, 0);
            _seq.Join(m.DOFloat(dissolveParam, dissolveParamName, effectDuration));
            _seq.Join(m.DOFloat(emissionParam, emissionParamName, effectDuration));
        }

        _seq.Play();
    }

    public void DissolveOut()
    {
        _seq?.Kill();
        _seq = DOTween.Sequence().SetLink(gameObject).SetEase(effectEaseOut);

        foreach (Material m in materials)
        {
            m.SetFloat(dissolveParamName, dissolveParam);
            m.SetFloat(emissionParamName, emissionParam);
            _seq.Join(m.DOFloat(0, dissolveParamName, effectDuration));
            _seq.Join(m.DOFloat(0, emissionParamName, effectDuration));
        }

        _seq.Play();
    }

    void GetMaterialsRecursively(Transform parent)
    {
        foreach (Transform child in parent)
        {
            MeshRenderer meshRenderer = child.GetComponent<MeshRenderer>();
            if (meshRenderer != null)
            {
                foreach (Material m in meshRenderer.materials)
                {
                    materials.Add(m);
                }
            }

            GetMaterialsRecursively(child);
        }
    }
}