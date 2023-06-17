using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstancingCreateCubeByInstantiate : MonoBehaviour
{
    static int baseColorID = Shader.PropertyToID("_BaseColor");
    static int positionDeltaID = Shader.PropertyToID("_PositionDelta");
    static int speedID = Shader.PropertyToID("_Speed");
    [SerializeField]
    GameObject cube;
    [SerializeField]
    int sum = 10000;
    [SerializeField]
    float instantiateRange = 50;
    [SerializeField]
    float positionDeltaRange = 10;
    [SerializeField]
    float speedRange = 10;
    MaterialPropertyBlock block;
    void Start()
    {
        block = new MaterialPropertyBlock();
        for (int i = 0; i < sum; i++)
        {
            var obj = Instantiate(cube);
            obj.transform.SetParent(transform, false);
            obj.transform.localPosition = Random.insideUnitSphere * instantiateRange;
            block.SetColor(baseColorID, new Color(Random.value, Random.value, Random.value));
            block.SetFloat(positionDeltaID, Random.Range(-positionDeltaRange, positionDeltaRange));
            block.SetFloat(speedID, Random.Range(-speedRange, speedRange));
            obj.GetComponent<MeshRenderer>().SetPropertyBlock(block);
            //obj.GetComponent<MeshRenderer>().material.SetColor(baseColorID, new Color(Random.value, Random.value, Random.value));
            //obj.GetComponent<MeshRenderer>().material.SetFloat(positionDeltaID, Random.Range(-positionDeltaRange, positionDeltaRange));
            //obj.GetComponent<MeshRenderer>().material.SetFloat(speedID, Random.Range(-speedRange, speedRange));
        }
    }
}
