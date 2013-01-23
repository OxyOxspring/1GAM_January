using UnityEngine;
using System.Collections;

public class FishScriptLogic : MonoBehaviour {
	
   	static GameObject Shark;
	private Vector2 SharkLocation;
	
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	Shark = GameObject.Find("EvilFish(Clone)");
	SharkLocation = Shark.transform.position;
	Debug.Log (Vector3.Distance(SharkLocation ,this.transform.position));
	if(Vector3.Distance(SharkLocation ,this.transform.position) < 11.6f)
		{
			Debug.Log("He dead!");
		}
	}

}
