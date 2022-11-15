using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateSelf : MonoBehaviour
{
    public bool isRotate;
    public float rotateSpeed;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (isRotate)
        {
            Quaternion rotU = Quaternion.AngleAxis(rotateSpeed / 100, Vector3.forward);
            gameObject.transform.rotation *= rotU;
        }
    }
}