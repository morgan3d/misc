using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class GameState : MonoBehaviour {

    public GameObject goodBallPrefab;
    public GameObject badBallPrefab;

    public Text scoreDisplay;
    int score = 0;

    const int maxGood = 8;
    const int maxBad = 2;

    public void changeScore(int delta) {
        score += delta;
        scoreDisplay.text = "" + score;
    }    

    public void Update() {
        MaybeSpawnBalls();
    }

    protected void MaybeSpawnBalls() {
        if (Random.value < 0.01f) {
            // Spawning time!
            bool makeBad = Random.value < 0.25f;

            if (makeBad) {
                // Prevent too many objects from appearing at once
                if (GameObject.FindGameObjectsWithTag("Bad").Length < maxBad) {
                    Instantiate(badBallPrefab);
                }
            } else {
                if (GameObject.FindGameObjectsWithTag("Good").Length < maxGood) {
                    Instantiate(goodBallPrefab);
                }
            }
        }
    }
}
