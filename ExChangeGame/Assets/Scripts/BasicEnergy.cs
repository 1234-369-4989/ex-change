using System.Collections;
using UnityEngine;

namespace DefaultNamespace
{
    public class BasicEnergy : MonoBehaviour
    {
        [field: SerializeField] public float Energy { get; private set; }
        [field: SerializeField] public float MaxEnergy { get; private set; }
        [SerializeField] private int energyRecoveryRate = 1;
        [SerializeField] private float energyRecoveryDelay = 1;
        private WaitForSeconds _energyRecoveryDelay;
        
        private void Start()
        {
            _energyRecoveryDelay = new WaitForSeconds(energyRecoveryDelay);
        }

        public bool Use(float amount)
        {
            if (Energy - amount < 0) return false;
            StopCoroutine(nameof(EnergyRecoveryCoroutine));
            Energy -= amount;
            StartCoroutine(nameof(EnergyRecoveryCoroutine));
            return true;
        }
        
        private IEnumerator EnergyRecoveryCoroutine()
        {
            yield return _energyRecoveryDelay;
            while (true)
            {
                Recover(energyRecoveryRate*Time.deltaTime);
                yield return null;
            }
        }

        public void Recover(float amount)
        {
            if ((Energy += amount) >= MaxEnergy) Energy = MaxEnergy;
        }

        public void FullHealth()
        {
            Energy = MaxEnergy;
        }
    }
}