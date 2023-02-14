using System.Collections;
using System.Collections.Generic;
using AmplifyShaderEditor;
using UnityEngine;

[ExecuteInEditMode]
public class ForceField : MonoBehaviour
{
    public ParticleSystem ps;
    public string triggerTag = "ForceField";
    public float clicksPerSecond = 0.1f;
    private float clickTimer = 0.0f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    void DoRayCast()
    {
        RaycastHit hitInfo;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray, out hitInfo, 1000) && hitInfo.transform.CompareTag(triggerTag))
        {
            ps.transform.position = hitInfo.point;
            ps.Emit(1);
        }
    }
    
    // Update is called once per frame
    void Update()
    {
        clickTimer += Time.deltaTime;
        if (Input.GetMouseButton(0))
        {
            if (clickTimer > clicksPerSecond)
            {
                clickTimer = 0.0f;
                DoRayCast();
            }   
        }
        
        /*Shader.SetGlobalVector("HitPosition",transform.position);
        Shader.SetGlobalFloat("HitSize",transform.localScale.x);*/
    }
}
