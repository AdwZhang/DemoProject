using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class CameraDepthImage : MonoBehaviour
{
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        //设置Camera的depthTextureMode,使得摄像机能生成深度图。
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination){
        Graphics.Blit(source,destination,material);
        //mat就是包含shader的一个材质球，而这个shader就是我们要把
        //destination这个render纹理传进去的shader。Shader的写法如下所示。
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
