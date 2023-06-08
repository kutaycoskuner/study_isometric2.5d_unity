using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotator : MonoBehaviour
{
    [SerializeField] private Vector3 _rotation;
    [SerializeField] private float _speed;
    [SerializeField] public GameObject _target;
 
    // Update is called once per frame
    void Update()
    {
        //transform.position = _target.transform.position;
        transform.Rotate(0, _speed * Time.deltaTime, 0);
    }
}
