using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Bar : MonoBehaviour
{
    //public Character hp_object;
    [SerializeField]
    private Image bar, delayBar;
    [SerializeField]
    private float speed;
    [SerializeField]
    private float value, maxValue, delayValue, valueRatio;

    // Start is called before the first frame update
    void Start()
    {
        value = maxValue;
        delayValue = maxValue;
    }

    // Update is called once per frame
    void Update()
    {
        decreaseGuage();
        if (Input.GetKeyDown(KeyCode.T))
        {
            DecreaseTest(20);
        }
    }

    private void decreaseGuage()
    {
        valueRatio = value / maxValue;
        bar.fillAmount = valueRatio;
        if(value < delayValue)
        {
            delayValue -= Time.unscaledDeltaTime * speed;
        }
        delayBar.fillAmount = delayValue / maxValue;
    }

    public void DecreaseTest(float testDmg)
    {
        value -= testDmg;
        if (value <= 0)
        {
            value = 0;
        }
    }
}
