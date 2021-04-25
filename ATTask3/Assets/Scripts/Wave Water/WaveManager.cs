using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveManager : MonoBehaviour
{
    public static WaveManager instance;

    public float amplitude = 1f; // Height of the waves
    public float length = 2f; // Length of the waves
    public float speed = 1f; // Speed the waves move at
    public float offset = 0f; // Position on the plane (increases over time to give impression the waves are moving across the plane)

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }

        else if (instance != null)
        {
            Destroy(this);
        }
    }

    private void Update()
    {
        offset += Time.deltaTime * speed;
    }

    public float GetWaveHeight(float z)
    {
        return amplitude * Mathf.Sin(z / length + offset);
    }
}
