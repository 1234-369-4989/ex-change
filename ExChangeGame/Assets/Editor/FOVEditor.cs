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

        Vector3 viewAngle01 = DirectionFromAngle(enemyBehavior.transform.eulerAngles.y, -enemyBehavior.angle / 2);
        Vector3 viewAngle02 = DirectionFromAngle(enemyBehavior.transform.eulerAngles.y, enemyBehavior.angle / 2);

        Handles.color = Color.red;
        Handles.DrawLine(enemyBehavior.transform.position, enemyBehavior.transform.position + viewAngle01 * enemyBehavior.CheckRadius);
        Handles.DrawLine(enemyBehavior.transform.position, enemyBehavior.transform.position + viewAngle02 * enemyBehavior.CheckRadius);
    }

    private Vector3 DirectionFromAngle(float eulerY, float angleInDegrees)
    {
        angleInDegrees += eulerY;

        return new Vector3(Mathf.Sin(angleInDegrees * Mathf.Deg2Rad), 0, Mathf.Cos(angleInDegrees * Mathf.Deg2Rad));
    }
}
