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
    public enum Levels
    {
        Level1,
        Level2,
        Level3
    }
    [SerializeField]
    Levels level = Levels.Level1;
    // Start is called before the first frame update
    void Start()
    {
        gameObject.layer = LayerMask.NameToLayer(level.ToString() + "Icon");
        transform.GetChild(0).gameObject.layer = LayerMask.NameToLayer(level.ToString() + "Icon");
        image = GetComponentInChildren<Image>();
        image.sprite = IconImage;
        gameObject.GetComponent<RectTransform>().anchoredPosition = offset;
    }
}
