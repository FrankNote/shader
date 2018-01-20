using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScanEffect : postEffectBase {
	private float dis;
	private float velotic = 5;
	private bool isScan;
	// Use this for initialization
	void Start () {
		Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {
		if(isScan)
			dis += Time.deltaTime * velotic;
		if (Input.GetKeyDown ("c")) {
			isScan = true;
			dis = 0;
		}
	}
	void OnRenderImage(RenderTexture sourceTexture,RenderTexture destTexture)
	{
		if (_Material) 
		{
			_Material.SetFloat("_ScanDistance",dis);
			Graphics.Blit (sourceTexture, destTexture,_Material);
		} 
		else
		{
			Graphics.Blit (sourceTexture, destTexture);
		}
	}
}
