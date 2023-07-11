using System;
using ExChangeParts;
using UnityEngine;
using UnityEngine.UI;

namespace UI
{
    public class UIPartchooserItem:MonoBehaviour
    {
        public Image Image {get; private set;}
        [field: SerializeField] public string Name {get; private set;}
        [field: SerializeField] public bool IsEnabled {get; private set;}
        [field:SerializeField] public ExchangePart PartGameObject {get; private set;}

        private void Awake()
        {
            Image = GetComponent<Image>();
            // set opacity to 0.5f if disabled
            
        }

        private void Start()
        {
            // set opacity to 0.5f if disabled
             if (!IsEnabled)
             {
                 Image.color = new Color(Image.color.r, Image.color.g, Image.color.b, 0.5f);
             }
        }

        public void Enable()
        {
            IsEnabled = true;
            Image.color = new Color(Image.color.r, Image.color.g, Image.color.b, 1f);
        }
    }
}