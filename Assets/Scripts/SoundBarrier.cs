using System.Collections;
using UnityEngine;

public class SoundBarrier : MonoBehaviour
{
    [SerializeField] float duration;
    [SerializeField] float expantionSpeed;
    private Material mat;

    private void Awake()
    {
        mat = GetComponent<MeshRenderer>().sharedMaterial;
        mat.SetFloat("_DistanceValue", 0);
    }

    private void Start()
    {
        StartCoroutine(Expand(Time.time + duration));
    }

    private IEnumerator Expand(float endTime)
    {
        while (Time.time < endTime)
        {
            yield return null;

            mat.SetFloat("_DistanceValue", mat.GetFloat("_DistanceValue") + expantionSpeed);
        }
    }
}
