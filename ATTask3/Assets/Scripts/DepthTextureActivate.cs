using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthTextureActivate : MonoBehaviour
{
    void Start()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }
}
