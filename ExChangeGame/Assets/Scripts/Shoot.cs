using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shoot : MonoBehaviour
{
   [SerializeField] private GameObject bulletPrefab;
   [SerializeField] private float bulletSpeed;
   [SerializeField] private float shootDelay;
   
   private float _shootTimer;
   
   private void Update()
   {
      _shootTimer += Time.deltaTime;
      if (_shootTimer >= shootDelay)
      {
        
            ShootBullet();
            _shootTimer = 0;
      }
   }
   
   private void ShootBullet()
   {
      var bullet = Instantiate(bulletPrefab, transform.position, Quaternion.identity);
      bullet.GetComponent<Rigidbody>().velocity = transform.forward * bulletSpeed;
   }
}
