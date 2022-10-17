using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EasyImage : PostEffectBase
{

    public Shader shader;
    private Material p_material;
    public Material n_material;

    [Range(0.0f,3.0f)]
    public float brightness = 1.0f;

    public Material material
    {
        get
        {
            p_material = CheckShaderAndCreateMaterial(shader, p_material);
            return p_material;
        }
    }
    
    
    
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        /*if (material != null)
        {
            material.SetFloat("_Brightness",brightness);
            Graphics.Blit(src,dest,material);
        }
        else
        {
            //Graphics.Blit(src,dest);
            n_material.SetFloat("_Brightness",brightness);
            Graphics.Blit(src,dest,n_material);
        }*/
        n_material.SetFloat("_Brightness",brightness);
        Graphics.Blit(src,dest,n_material);
    }
}
