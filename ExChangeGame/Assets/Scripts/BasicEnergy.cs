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
            Debug.Log("Using energy");
            if (Energy - amount < 0) return false;
            StopCoroutine(nameof(EnergyRecoveryCoroutine));
            Debug.Log("Energy used: " + amount);
            Energy -= amount;
            Debug.Log("Energy: " + Energy);
            StartCoroutine(nameof(EnergyRecoveryCoroutine));
            return true;
        }
        
        private IEnumerator EnergyRecoveryCoroutine()
        {
            Debug.Log("Starting energy recovery");
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