using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial;

    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader,gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    // 迭代次数
    [Range(0,4)]
    public int iterations = 3;
    
    // 模糊范围
    [Range(0.2f,3.0f)]
    public float blurSpread = 0.6f;

    // 缩放系数
    [Range(1,8)]
    public int downSample = 2;
    
    /// 3rd edition: use iterations for larger blur
    /// 考虑了高斯模糊的迭代次数
    void OnRenderImage(RenderTexture src, RenderTexture dest){
        if(material!=null){
            int rtW=src.width/downSample;
            int rtH=src.height/downSample;

            RenderTexture buffer0=RenderTexture.GetTemporary(rtW,rtH,0);
            buffer0.filterMode=FilterMode.Bilinear;

            Graphics.Blit(src,buffer0);

            for(int i=0;i<iterations;i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the vertical pass
                Graphics.Blit(buffer0,buffer1,material,0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0=buffer1;
                buffer1=RenderTexture.GetTemporary(rtW,rtH,0);

                // Render the horizontal pass
                Graphics.Blit(buffer0,buffer1,material,1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0=buffer1;
            }

            Graphics.Blit(buffer0,dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }else{
            Graphics.Blit(src,dest);
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
}
