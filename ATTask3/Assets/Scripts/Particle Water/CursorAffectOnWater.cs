using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CursorAffectOnWater : MonoBehaviour
{
    [Header("Mouse Setup")]
    public float affectRange;
    public float affectForce;
    
    private void FixedUpdate()
    {
        if (Input.GetButton("Fire1"))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition); // Ray from the camera to the mouse position
            RaycastHit hit; // Hit data for our ray

            if (Physics.Raycast(ray, out hit)) // Checks if that ray has hit something
            {
                AffectObjects(hit.point);
            }
        }
    }

    void AffectObjects(Vector3 positionToAffect)
    {
        Debug.Log(positionToAffect);

        Vector3 explosionPos = positionToAffect;
        Collider[] colliders = Physics.OverlapSphere(explosionPos, affectRange);
        foreach (Collider hit in colliders)
        {
            Rigidbody rb = hit.GetComponent<Rigidbody>();

            if (rb != null)
                rb.AddExplosionForce(affectForce, explosionPos, affectRange, 3.0F);
        }
    }
}
