using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(SawEnemyBehavior))]
public class SawEnemyEditor : Editor
{
    private void OnSceneGUI()
    {
        SawEnemyBehavior enemyBehavior = (SawEnemyBehavior)target;
        Handles.color = Color.white;
        Handles.DrawWireArc(enemyBehavior.transform.position, Vector3.up, Vector3.forward, 360, enemyBehavior.CheckRadius);

        Handles.color = Color.red;
        Handles.DrawWireArc(enemyBehavior.transform.position, Vector3.up, Vector3.forward, 360, enemyBehavior.AttackDist);

        Handles.color = Color.yellow;
        Handles.DrawWireArc(enemyBehavior.transform.position, Vector3.up, Vector3.forward, 360, enemyBehavior.MinDist);

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
