using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class motionBlurEffect : postEffectBase {

	[Range (5,50)]
	public float iterationNum = 15;
	[Range (-0.5f,0.5f)]
	public float intensity = 0.125f;
	void OnRenderImage(RenderTexture sourceTexture,RenderTexture destTexture)
	{
		if (_Material) 
		{
			_Material.SetFloat("_Intensity",intensity);
			_Material.SetFloat("_IterationNumber",iterationNum);
			_Material.SetVector("center",new Vector2(0.5f,0.5f));
			Graphics.Blit (sourceTexture, destTexture,_Material);
		} 
		else
		{
			Graphics.Blit (sourceTexture, destTexture);
		}
	}

}
