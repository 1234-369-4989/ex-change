using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MinimapIcon : MonoBehaviour
{
    [SerializeField]
    private Sprite IconImage;
    private Image image;

    [SerializeField]
    private Vector3 offset;
    // Start is called before the first frame update
    void Start()
    {
        image = GetComponentInChildren<Image>();
        image.sprite = IconImage;
        gameObject.GetComponent<RectTransform>().anchoredPosition = offset;
    }
}
