using UnityEngine;
using System.Collections;

public class Ball : MonoBehaviour {
    public new Rigidbody rigidbody;
    public float speed;

    protected static Bounds spawnBounds = new Bounds(new Vector3(0.0f, 0.6f, 5.0f), new Vector3(2.0f, 0.5f, 0.0f));

	// Use this for initialization
	void Start() {
        transform.position = new Vector3(
            Random.Range(spawnBounds.min.x, spawnBounds.max.x),
            Random.Range(spawnBounds.min.y, spawnBounds.max.y),
            Random.Range(spawnBounds.min.z, spawnBounds.max.z));

        rigidbody.velocity = new Vector3(0, 0, speed / Application.targetFrameRate);
        rigidbody.angularVelocity = new Vector3(Random.value, Random.value, Random.value) * 3.0f - new Vector3(1.5f, 1.5f, 1.5f);
	}

    void FixedUpdate() {
        if (transform.position.z < -3.0f) {
            // Past the far wall
            Destroy(gameObject);
        }
    }
}
