using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial;
    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f,1.0f)]
    public float edgeOnly = 0.0f;
    
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    protected void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            
            Graphics.Blit(src,dest,material);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
