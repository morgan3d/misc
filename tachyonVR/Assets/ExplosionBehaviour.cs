using UnityEngine;
using System.Collections;

public class ExplosionBehaviour : MonoBehaviour {
    // Unity has its own, deprecated "particleSystem" member that
    // the auto-upgrade scripts will replace with GetComponent<ParticleSystem>()
    // if we use the same name, so I put an underscore here.
    private ParticleSystem _particleSystem;

	void Start () {
	    _particleSystem = GetComponent<ParticleSystem>();
	}
	
	void Update () {
        if (_particleSystem && !_particleSystem.IsAlive()) { 
            // Animation is complete
            Destroy(gameObject);
        }	
	}
}
