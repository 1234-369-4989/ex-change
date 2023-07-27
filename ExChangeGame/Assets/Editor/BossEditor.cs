using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(BossBehavior))] 
public class BossEditor : Editor
{
   private void OnSceneGUI()
   {
      BossBehavior bossBehavior = (BossBehavior)target;

      Handles.color = Color.red;
      Handles.DrawWireArc(bossBehavior.transform.position, Vector3.up, Vector3.forward, 360, bossBehavior.ShootRadius);

      Handles.color = Color.yellow;
      Handles.DrawWireArc(bossBehavior.transform.position, Vector3.up, Vector3.forward, 360, bossBehavior.CQCRadius);
   }
}
