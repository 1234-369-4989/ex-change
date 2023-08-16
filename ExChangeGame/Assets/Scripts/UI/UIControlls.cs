using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class UIControlls : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI jump;
    [SerializeField] private TextMeshProUGUI repair;
    [SerializeField] private TextMeshProUGUI shoot;
    
    void Start()
    {
        setAllControllsActiveFalse();
    }

    public void setAllControllsActiveFalse()
    {
        setJumpActiveFalse();
        setRepairActiveFalse();
        setShootActiveFalse();
    }
    
    
    public void setJumpActiveFalse()
    {
        jump.gameObject.SetActive(false);
    }
    
    public void setJumpActiveTrue()
    {
        jump.gameObject.SetActive(true);
    }
    
    
    public void setRepairActiveFalse()
    {
        repair.gameObject.SetActive(false);
    }
    
    public void setRepairActiveTrue()
    {
        repair.gameObject.SetActive(true);
    }
    
    
    public void setShootActiveFalse()
    {
        shoot.gameObject.SetActive(false);
    }
    
    public void setShootActiveTrue()
    {
        shoot.gameObject.SetActive(true);
    }


   
}
