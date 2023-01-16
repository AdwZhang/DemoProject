using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateSelf : MonoBehaviour
{
    public bool isRotate = true;
    public float rotateSpeed = 30.0f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (isRotate)
        {
            Quaternion rotU = Quaternion.AngleAxis(rotateSpeed / 100, Vector3.up);
            gameObject.transform.rotation *= rotU;
        }
    }
}
