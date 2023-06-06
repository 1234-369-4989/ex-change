using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MinimapCamera : MonoBehaviour
{
    public GameObject Player;
    public GameObject MainCamera;

    // Start is called before the first frame update
    void Start()
    {
        MainCamera.GetComponent<Camera>().cullingMask &= ~(1 << LayerMask.NameToLayer("Minimap"));
        Vector3 pos = Player.transform.position;
        //float defaultAngle = Player.transform.localEulerAngles.y;
        pos.y = 20f;
        gameObject.transform.position = pos;
        transform.parent = Player.transform;
    }

    // Update is called once per frame
    void Update()
    {
        float angle = MainCamera.transform.localEulerAngles.y;
        gameObject.transform.rotation = Quaternion.Euler(90f, angle, 90f);
    }
}
