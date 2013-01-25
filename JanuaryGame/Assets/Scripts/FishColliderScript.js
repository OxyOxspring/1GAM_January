#pragma strict

private var health:int;
var bloodstream:ParticleSystem;
var chomp:AudioSource;

function OnTriggerEnter(object:Collider){

if(object.gameObject.name == "EvilFish(Clone)")
{
health -= 20;
fadeOut();
chomp.Play();
}

}


function Start () {
health = 100;
bloodstream.Stop();
}

function Update () {
if(health <= 60)
{
networkView.RPC("blood",RPCMode.AllBuffered);
}

if(health <= 0)
{
Network.CloseConnection(Network.connections[0], true);
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


@RPC
function blood(){
bloodstream.Play();
}