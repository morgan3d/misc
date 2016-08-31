using UnityEngine;
using System.Collections;

public class ExplosionBehaviour : MonoBehaviour {
    private ParticleSystem particleSystem;

	void Start () {
	    particleSystem = GetComponent<ParticleSystem>();
	}
	
	void Update () {
        if (particleSystem && ! particleSystem.IsAlive()) { 
            // Animation is complete
            Destroy(gameObject);
        }	
	}
}
