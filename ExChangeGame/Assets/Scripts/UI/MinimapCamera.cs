using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MinimapCamera : MonoBehaviour
{
    public GameObject Player;
    public GameObject MainCamera;

    private int nowLevel;
    private Camera mapCamera;

    // Start is called before the first frame update
    void Start()
    {
        mapCamera = gameObject.GetComponent<Camera>();
        MainCamera.GetComponent<Camera>().cullingMask &= ~(1 << LayerMask.NameToLayer("Minimap"));
        Vector3 pos = Player.transform.position;
        pos.y = 20f;
        gameObject.transform.position = pos;
        transform.parent = Player.transform;
    }

    void Update()
    {
        mapFloorChange();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        float angle = MainCamera.transform.eulerAngles.y;
        gameObject.transform.rotation = Quaternion.Euler(90f, angle, 0);
        //mapFloorChange();
    }

    void mapFloorChange()
    {
        if(Player.transform.position.y < -4 && nowLevel != 3)
        {
            mapCamera.cullingMask = 1 << LayerMask.NameToLayer("Level3");
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Minimap");
            nowLevel = 3;
        }
        else if (-4 <Player.transform.position.y && Player.transform.position.y < 0 && nowLevel != 2)
        {
            mapCamera.cullingMask = 1 << LayerMask.NameToLayer("Level2");
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Minimap");
            nowLevel = 2;
            Debug.Log("level2");
        }
        else if (Player.transform.position.y > 0  && nowLevel != 1)
        {
            mapCamera.cullingMask = 1 << LayerMask.NameToLayer("Level1");
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Minimap");
            nowLevel = 1;
            Debug.Log("level1");
        }
    }
}
