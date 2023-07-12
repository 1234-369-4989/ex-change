using System;
using ExChangeParts;
using TMPro;
using UI;
using UnityEngine;
using UnityEngine.UI;

public class UI_PartChooser : MonoBehaviour
{
    public event Action<UIPartchooserItem> OnPartSelected;

    [field: SerializeField] public UIPartchooserItem[] Items { get; private set; }
    [SerializeField] private ExchangePart defaultPart;
    private bool _hasDefaultPart;
    [SerializeField] private Button chooserLeft;
    [SerializeField] private Button chooserRight;
    [SerializeField] private TextMeshProUGUI chooserName;
    [SerializeField] private TextMeshProUGUI questionMark;

    private int _currentItemIndex = -1;


    private void Start()
    {
        _hasDefaultPart = defaultPart != null;
        chooserLeft.onClick.AddListener(OnLeftClick);
        chooserRight.onClick.AddListener(OnRightClick);
        UpdateUI();
    }

    private void UpdateUI()
    {
        foreach (var item in Items)
        {
            if (_hasDefaultPart) defaultPart.gameObject.SetActive(false);
            item.PartGameObject.gameObject.SetActive(false);
            item.gameObject.SetActive(false);
        }

        if (_currentItemIndex == -1)
        {
            chooserName.text = "";
            questionMark.gameObject.SetActive(false);
            if (_hasDefaultPart) defaultPart.gameObject.SetActive(true);
            return;
        }

        var currentItem = Items[_currentItemIndex];
        questionMark.gameObject.SetActive(currentItem.IsEnabled == false);
        currentItem.gameObject.SetActive(true);
        currentItem.PartGameObject.gameObject.SetActive(true);
        chooserName.text = currentItem.IsEnabled ? currentItem.Name : "???";
    }

    private void OnRightClick()
    {
        _currentItemIndex++;
        if (_currentItemIndex >= Items.Length) _currentItemIndex = -1;
        // check if item is enabled
        UpdateUI();

        OnPartSelected?.Invoke(_currentItemIndex == -1 ? null : Items[_currentItemIndex]);
    }

    private void OnLeftClick()
    {
        _currentItemIndex--;
        if (_currentItemIndex < -1) _currentItemIndex = Items.Length - 1;
        // check if item is enabled
        UpdateUI();
        OnPartSelected?.Invoke(_currentItemIndex == -1 ? null : Items[_currentItemIndex]);
    }

    public UIPartchooserItem GetCurrentItem => _currentItemIndex == -1 ? null : Items[_currentItemIndex];

    public void SetCurrentItem(ExchangePart part)
    {
        for (var i = 0; i < Items.Length; i++)
        {
            if (Items[i].PartGameObject.GetType() == part.GetType())
            {
                _currentItemIndex = i;
                UpdateUI();
                OnPartSelected?.Invoke(_currentItemIndex == -1 ? null : Items[_currentItemIndex]);
                return;
            }
        }
    }
}