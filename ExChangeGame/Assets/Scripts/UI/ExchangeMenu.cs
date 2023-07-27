using System;
using System.Collections.Generic;
using System.Linq;
using ExChangeParts;
using UnityEngine;
using UnityEngine.UI;

namespace UI
{
    [RequireComponent(typeof(AudioSource))]
    public class ExchangeMenu : MonoBehaviour
    {
        [SerializeField] private GameObject exchangeMenu;
        [SerializeField] private UI_PartChooser[] partChoosers;
        private UIPartchooserItem[] _items;
        [SerializeField] private Button okButton;
        [SerializeField] private Button cancelButton;
        [SerializeField] private bool allActive;
        
        private AudioSource _audioSource;
        
        private readonly Dictionary<Type, UI_PartChooser> _itemChooserMap = new();
        
        public bool IsOpen => exchangeMenu.activeSelf;
        
        public event Action OnExchangeMenuOpened;
        public event Action OnExchangeMenuClosed;
        
        private void Awake()
        {
            foreach (var chooser in partChoosers)
            {
                chooser.OnPartSelected += OnChooserChanged;
            }
            _audioSource = GetComponent<AudioSource>();
        }

        private void Start()
        {
            foreach (var chooser in partChoosers)
            {
                foreach (var item in chooser.Items)
                {
                    _itemChooserMap.Add(item.PartGameObject.GetType(), chooser);
                }
                if(allActive) chooser.SetAllActive();
                if(chooser.GetCurrentItem != null && !chooser.GetCurrentItem.IsEnabled) okButton.interactable = false;
            }
            okButton.onClick.AddListener(OnOkButtonPressed);
            cancelButton.onClick.AddListener(CloseMenu);
            exchangeMenu.SetActive(false);
        }
        
        public void OpenMenu()
        {
            foreach (ExchangePart part in ExchangeSystem.Instance.GetParts())
            {
                Debug.Log(part);
                if(_itemChooserMap.ContainsKey(part.GetType()) == false){ continue;}
                var chooser = _itemChooserMap[part.GetType()];
                chooser.SetCurrentItem(part);
            }
            exchangeMenu.SetActive(true);
            OnExchangeMenuOpened?.Invoke();
        }

        public void CloseMenu()
        {
            exchangeMenu.SetActive(false);
            OnExchangeMenuClosed?.Invoke();
        }

        public void OnChooserChanged(UIPartchooserItem item)
        {
            Debug.Log("Chooser changed");
            var valid = partChoosers.All(chooser => chooser.GetCurrentItem == null || chooser.GetCurrentItem.IsEnabled);
            okButton.interactable = valid;
        }

        public void OnOkButtonPressed()
        {
            Debug.Log("OK");
            var parts = new List<ExchangePart>();
            foreach (var chooser in partChoosers)
            {
                var part = chooser.GetCurrentItem;
                if (part != null) parts.Add(part.PartGameObject);
                else if (chooser.DefaultPart) parts.Add(chooser.DefaultPart);
                else ExchangeSystem.Instance.RemovePart(chooser.PartPosition);
            }
            //TODO Exchange Animation
            _audioSource.Play();
            ExchangeSystem.Instance.ChangeParts(parts);
            CloseMenu();
        }

    }
}