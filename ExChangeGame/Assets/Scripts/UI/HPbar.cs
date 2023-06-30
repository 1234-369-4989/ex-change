using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HPbar : MonoBehaviour
{
    public BasicHealth playerHealth;
    [SerializeField]
    private Image bar, delayBar;
    [SerializeField]
    private float speed = 20;
    [SerializeField]
    private float maxValue = 100;

    private float value, delayValue, lastValue,valueRatio;

    // Start is called before the first frame update
    void Start()
    {
        //You may have to make maxvalue a public variable to get it to work.
        //if you add BasicHealth script, enable thisÅ´
        //maxValue = playerHealth.maxHealth;
        value = playerHealth.Health;
        delayValue = maxValue;
        lastValue = maxValue;
    }

    // Update is called once per frame
    void Update()
    {
        decreaseGuage();
        healGuage();
    }

    private void decreaseGuage()
    {
        value = playerHealth.Health;
        valueRatio = value / maxValue;
        bar.fillAmount = valueRatio;
        if (value < delayValue)
        {
            delayValue -= Time.unscaledDeltaTime * speed;
        }
        delayBar.fillAmount = delayValue / maxValue;
    }

    private void healGuage()
    {
        if(lastValue < value)
        {
            delayValue = value;
        }
        lastValue = value;
    }
}
