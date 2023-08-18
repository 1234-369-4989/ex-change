using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class MinimapCamera : MonoBehaviour
{
    public GameObject Player;
    public GameObject MainCamera;
    [SerializeField]
    private float height1to2 = 0;
    [SerializeField]
    private float height2to3 = -4;
    private int nowLevel;
    private Camera mapCamera;
    
    
    public static event Action<int> OnOnLevelChange;

    // Start is called before the first frame update
    void Start()
    {
        mapCamera = gameObject.GetComponent<Camera>();
        MainCamera.GetComponent<Camera>().cullingMask &= ~(1 << LayerMask.NameToLayer("Minimap"));
        mapFloorChange();
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
    void LateUpdate()
    {
        float angle = MainCamera.transform.eulerAngles.y;
        gameObject.transform.rotation = Quaternion.Euler(90f, angle, 0);
    }

    void mapFloorChange()
    {
        if(Player.transform.position.y < height2to3 && nowLevel != 3)
        {
            // mapCamera.cullingMask = 1 << LayerMask.NameToLayer("Level3");
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Level3Icon");
            // deactivate level 2 and level 1
            mapCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("Level2Icon"));
            mapCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("Level1Icon"));
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Minimap");
            nowLevel = 3;
            OnOnLevelChange?.Invoke(3);
        }
        else if (height2to3 <Player.transform.position.y && Player.transform.position.y < height1to2 && nowLevel != 2)
        {
            // mapCamera.cullingMask = 1 << LayerMask.NameToLayer("Level2");
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Level2Icon");
            // deactivate level 3 and level 1
            mapCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("Level3Icon"));
            mapCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("Level1Icon"));
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Minimap");
            nowLevel = 2;
            OnOnLevelChange?.Invoke(2);
        }
        else if (Player.transform.position.y > height1to2  && nowLevel != 1)
        {
            // mapCamera.cullingMask = 1 << LayerMask.NameToLayer("Level1");
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Level1Icon");
            // deactivate level 2 and level 3
            mapCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("Level2Icon"));
            mapCamera.cullingMask &= ~(1 << LayerMask.NameToLayer("Level3Icon"));
            mapCamera.cullingMask |= 1 << LayerMask.NameToLayer("Minimap");
            nowLevel = 1;
            OnOnLevelChange?.Invoke(1);
        }
    }
}
