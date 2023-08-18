using UnityEngine;

namespace ExChangeParts
{
    // antennas should trigger the UI minimap
    public class MapSensor: ExchangePart
    {
        private GameObject _minimap;
        [SerializeField] private AudioSource _audioSource;

        protected override void OnEquip()
        {
            // UI minimap active
            if(!_minimap) _minimap = UIManager.Instance.MiniMap;
            _minimap.SetActive(true);
            _audioSource.Play();
        }

        protected override void OnUnequip()
        {
            // UI minimap inactive
            if(!_minimap) _minimap = UIManager.Instance.MiniMap;
            _minimap.SetActive(false);
        }
    }
}