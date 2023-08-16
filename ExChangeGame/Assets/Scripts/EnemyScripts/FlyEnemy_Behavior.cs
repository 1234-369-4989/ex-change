using UnityEngine;



public class FlyEnemy_Behavior : EnemyBehavior
{
    
    [Header("Shooting Variables")]
    [SerializeField] private float timer = 5f;
    [SerializeField] private float bulletSpeed = 5f;
    [SerializeField] private Vector3 offSet;
    private float _bulletTime;
    public GameObject EnemyBullet;
    public Transform SpawnPoint;
    
    [Header("Audio")]
    [SerializeField] private AudioSource hoverSound;
    [SerializeField] private AudioSource shootSound;

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

          shootSound.Play();  
        GameObject bulletObject =
            Instantiate(EnemyBullet, SpawnPoint.transform.position, transform.rotation);
        Rigidbody bulletRigidbody = bulletObject.GetComponent<Rigidbody>();

        /*
            *for some reason there is a negative offset between the playermodel and the playerentity,
            * therefore it needs to shoot at the Cameraroot,
            * since it is the only component right above our player model
            */
        Vector3 direction = (Player.transform.position+offSet) - transform.position;
        direction.Normalize();
        bulletRigidbody.AddForce(direction * bulletSpeed, ForceMode.Impulse);
    }

    protected override void OnDeath(BasicHealth h)
    {
        base.OnDeath(h);
        hoverSound.Stop();
    }
}
