using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnObjects : MonoBehaviour
{
    [Header("Spawner Setup")]
    public int numnberToSpawn;
    public GameObject particlePrefab;

    private void Start()
    {
        Invoke("Spawn", 0);
    }

    void Spawn()
    {
        for (int i = 0; i < numnberToSpawn; i++)
        {
            Instantiate(particlePrefab, GenerateNewPosition(), transform.rotation);
        }
    }

    Vector3 GenerateNewPosition()
    {
        Vector3 newPosition = new Vector3(Random.Range(-4.5f, 4.5f), Random.Range(1f, 4f), Random.Range(-4.5f, 4.5f));

        return newPosition;
    }
}
