using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class bloom : postEffectBase {
	public int sampleScale = 1;
	public int downScale = 1;
	public Color colorThreshold = Color.gray;
	public Color bloomColor = new Vector4 (1,1,1,1);
	[Range (0.0f,1.0f)]
	public float bloomFactor = 0.5f;
	void OnRenderImage(RenderTexture sourceTexture,RenderTexture destTexture)
	{
		if (_Material) 
		{
			RenderTexture temp1 = RenderTexture.GetTemporary (sourceTexture.width >> downScale, sourceTexture.height >> downScale);
			RenderTexture temp2 = RenderTexture.GetTemporary (sourceTexture.width >> downScale, sourceTexture.height >> downScale);
			Graphics.Blit (sourceTexture, temp1);

			_Material.SetVector("_colorThreshold",colorThreshold);
			Graphics.Blit (temp1, temp2,_Material,0);

			_Material.SetVector("_offsets",new Vector4(0,sampleScale,0,0));
			Graphics.Blit (temp2, temp1,_Material,1);

			_Material.SetVector("_offsets",new Vector4(sampleScale,0,0,0));
			Graphics.Blit (temp1, temp2,_Material,1);

			_Material.SetTexture ("_BlurTex",temp2);
			_Material.SetVector("_bloomColor",bloomColor);
			_Material.SetFloat("_bloomFactor",bloomFactor);
			Graphics.Blit (sourceTexture, destTexture,_Material,2);
			RenderTexture.ReleaseTemporary (temp1);
			RenderTexture.ReleaseTemporary (temp2);
		} 
		else
		{
			Graphics.Blit (sourceTexture, destTexture);
		}
	}

}

