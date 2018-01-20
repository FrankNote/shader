using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class waterWave : postEffectBase {
	public float distanceFactor = 30.0f;
	public float timeFactor = 5.0f;
	public float totalFactor = 1.0f;
	void OnRenderImage(RenderTexture sourceTexture,RenderTexture destTexture)
	{
		if (_Material) 
		{
			_Material.SetFloat("_distanceFactor",distanceFactor);
			_Material.SetFloat("_timeFactor",timeFactor);
			_Material.SetFloat("_totalFactor",totalFactor);
			Graphics.Blit (sourceTexture, destTexture,_Material);
		} 
		else
		{
			Graphics.Blit (sourceTexture, destTexture);
		}
	}
}
