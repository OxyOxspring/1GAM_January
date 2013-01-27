

private var health:int;
var chomp:AudioSource;

function OnTriggerEnter(object:Collider){

if(object.transform.parent.gameObject.name == "GoodFish(Clone)")
{
if(networkView.isMine)
{
health += 50;
fadeOut();
chomp.Play();
}
}

}


function Start () {
health = 100;
}

function Update () {
if(networkView.isMine){

}
}

var fadeOutTexture : Texture2D;
var fadeSpeed = 0.3;

var drawDepth = -1000;

//--------------------------------------------------------------------
//                       Private variables
//--------------------------------------------------------------------

private var alpha = 0.0; 

private var fadeDir = -1;

//--------------------------------------------------------------------
//                       Runtime functions
//--------------------------------------------------------------------

function OnGUI(){
if(networkView.isMine){
    alpha += fadeDir * fadeSpeed * Time.deltaTime;  
    alpha = Mathf.Clamp01(alpha);   

    GUI.color.a = alpha;

    GUI.depth = drawDepth;

    GUI.DrawTexture(Rect(0, 0, Screen.width, Screen.height), fadeOutTexture);
   }
}

//--------------------------------------------------------------------

//--------------------------------------------------------------------

//--------------------------------------------------------------------

function fadeOut(){
    fadeDir = 1;    
    yield WaitForSeconds (0.5);
    fadeDir = -1;
}



