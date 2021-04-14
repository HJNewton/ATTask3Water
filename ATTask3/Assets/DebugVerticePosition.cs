using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugVerticePosition : MonoBehaviour
{
    private MeshFilter meshFilter;
    public Material wavesMaterial;
    public Material depthMaterial;
    Vector3[] vertices;

    private void Awake()
    {
        meshFilter = this.GetComponent<MeshFilter>();
    }

    private void Update()
    {

    }
}
