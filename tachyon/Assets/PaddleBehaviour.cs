using UnityEngine;
using System.Collections;

public class PaddleBehaviour : MonoBehaviour {

    /** In m/s */
    public float maxVelocity;
    public Bounds movementBounds;
    public Transform cameraTransform;
    public GameState gameState;

    public Color badColor;
    public Color goodColor;
    public Color defaultColor;

    public GameObject explosionPrefab;

	// Use this for initialization
	void Start() {
        transform.position = movementBounds.center;
	
	}
	
	// Update is called once per frame
	void FixedUpdate() {
        transform.position = 
            new Vector3(Mathf.Clamp(transform.position.x - Input.GetAxis("Horizontal") * maxVelocity * -Time.deltaTime, movementBounds.min.x, movementBounds.max.x), 
                        Mathf.Clamp(transform.position.y - Input.GetAxis("Vertical") * maxVelocity * -Time.deltaTime, movementBounds.min.y, movementBounds.max.y), 
                        movementBounds.center.z);

        cameraTransform.position = new Vector3(
            (transform.position.x - movementBounds.center.x) * 0.15f,
            (transform.position.y - movementBounds.center.y) * 0.1f + 1.0f, 
            -3.0f);
	}


    void Update() {
        SetColorBasedOnOverlap();
    }


    protected void SetColorBasedOnOverlap() {
        Material material = GetComponentInChildren<MeshRenderer>().material;

        material.SetColor("_EmissionColor", defaultColor);

        // See if the paddle overlaps any good or bad objects and change its color if so
        foreach(GameObject good in GameObject.FindGameObjectsWithTag("Good")) {
            if (OverlapsPaddle(good)) {
                material.SetColor("_EmissionColor", goodColor);
                break;
            }
        }

        // Let bad override good
        foreach(GameObject bad in GameObject.FindGameObjectsWithTag("Bad")) {
            if (OverlapsPaddle(bad)) {
                material.SetColor("_EmissionColor", badColor);
                break;
            }
        }
    }
    

    protected bool OverlapsPaddle(GameObject ball) {
        Bounds bounds = GetComponent<BoxCollider>().bounds;

        return (ball.transform.position.z > transform.position.z) && 
            (Mathf.Abs(ball.transform.position.x - transform.position.x) < bounds.extents.x) &&
            (Mathf.Abs(ball.transform.position.y - transform.position.y) < bounds.extents.y);
    }


    protected void MakeExplosion(Vector3 position, Color color) {
        GameObject explosion = Instantiate(explosionPrefab);
        explosion.GetComponent<ParticleSystem>().startColor = color;
        explosion.transform.position = position;
    }


    void OnTriggerEnter(Collider collider) {
        if (collider.gameObject.CompareTag("Good")) {
            gameState.changeScore(100);
            MakeExplosion(collider.gameObject.transform.position, goodColor);
        }

        if (collider.gameObject.CompareTag("Bad")) {
            MakeExplosion(collider.gameObject.transform.position, badColor);
        }

        Destroy(collider.gameObject);
    }
}
