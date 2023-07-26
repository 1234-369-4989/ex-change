using UnityEngine;

namespace ExChangeParts
{
    // antennas should trigger the UI minimap
    public class EnemySensor: ExchangePart
    {
        private Camera _mainCamera;

        private void Start()
        {
            _mainCamera = MainCameraSingleton.Instance.Camera;
        }

        protected override void OnEquip()
        {
            // add layer to camera
            _mainCamera.cullingMask |= 1 << LayerMask.NameToLayer("EnemyUI");
        }

        protected override void OnUnequip()
        {
            // UI minimap inactive
            _mainCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("EnemyUI"));
        }
    }
}