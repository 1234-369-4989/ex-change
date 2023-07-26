using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;


public class FlyEnemy_Behavior : EnemyBehavior
{
    
    [Header("Shooting Variables")]
    [SerializeField] private float timer = 5f;
    [SerializeField] private float bulletSpeed = 5f;
    private float _bulletTime;
    public GameObject EnemyBullet;
    public Transform SpawnPoint;

    /// <summary>
    /// As an Attack the robot "charges up" a shot then shoots at the player an instance of the Gameobject "Bullet"
    /// </summary>
    public override void Attack()
    {
        _agent.destination = transform.position;// lock the robot in place while Shooting at player
        transform.LookAt(Player);
        ShootAtPlayer();
    }

    private void ShootAtPlayer()
    {
        _bulletTime -= Time.deltaTime;

        if (_bulletTime > 0) return;//do not shoot until "charging" complete

        _bulletTime = timer;

        GameObject bulletObject =
            Instantiate(EnemyBullet, SpawnPoint.transform.position, transform.rotation);
        Rigidbody bulletRigidbody = bulletObject.GetComponent<Rigidbody>();

        /*
            *for some reason there is a negative offset between the playermodel and the playerentity,
            * therefore it needs to shoot at the Cameraroot,
            * since it is the only component right above our player model
            */
        Vector3 direction = Player.transform.position - transform.position;
        direction.Normalize();
        bulletRigidbody.AddForce(direction * bulletSpeed, ForceMode.Impulse);
        
    }
}
