using System;
using Environment;
using ExChangeParts;
using UnityEngine;

public class PartExchanger : ActivateOnPlayerTrigger
{
   [SerializeField] private ExchangePart neededType;
   [SerializeField] private ExchangePart givenType;

   private void Awake()
   {
       if(neededType) neededType.gameObject.SetActive(false);
       if(givenType) givenType.gameObject.SetActive(true);
   }

   protected override void Activate()
   {
       if(!ExchangeSystem.Instance.HasPartEquipped(neededType)) return;
       ExchangeSystem.Instance.ChangeParts(neededType, givenType);
       givenType.gameObject.SetActive(false);
       neededType.gameObject.SetActive(true);
   }
}
