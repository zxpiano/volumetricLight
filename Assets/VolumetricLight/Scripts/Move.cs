using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    public bool moveX, moveY, moveZ;

    float originX, originY, originZ;
    void Start()
    {
        originX = transform.position.x;
        originY = transform.position.y;
        originZ = transform.position.z;
    }

    void Update()
    {
        if (moveX)
        {
            transform.position = new Vector3(originX + Mathf.Cos(Time.time), originY, originZ);
        }

        if (moveY)
        {
            transform.position = new Vector3(originX, originY + Mathf.Cos(Time.time), originZ);
        }

        if (moveZ)
        {
            transform.position = new Vector3(originX, originY, originZ + Mathf.Cos(Time.time));
        }

    }
}
