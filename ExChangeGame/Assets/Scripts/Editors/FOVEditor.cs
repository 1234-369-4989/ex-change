using System;
using System.Collections;
using System.Collections.Generic;
using System.Numerics;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;

[CustomEditor(typeof(EnemyBehavior))]
public class FOVEditor : Editor
{
    private void OnSceneGUI()
    {
        EnemyBehavior enemyBehavior = (EnemyBehavior)target;
        Handles.color = Color.white;
        Handles.DrawWireArc(enemyBehavior.transform.position, Vector3.up, Vector3.forward, 360, enemyBehavior.CheckRadius);
    }
}
