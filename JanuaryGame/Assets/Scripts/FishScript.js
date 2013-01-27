#pragma strict

private var health:int;
var bloodstream:ParticleSystem;
var chomp:AudioSource;
var chase:AudioSource;

var networking:GameObject;

private var count:int;

private var escapeCounter:int;


function OnTriggerEnter(object:Collider){

if(object.gameObject.name == "EvilFish(Clone)")
{
if(networkView.isMine)
{
networking.SendMessage("AttackedFish");
health -= 50;
fadeOut();
chomp.Play();
}
}

}


function Start () {
health = 100;
count = 0;
escapeCounter = 0;
bloodstream.Stop();
networking = GameObject.Find("NetworkManager");
}

function Update () {
if(networkView.isMine){
if(health <= 50)
{
networkView.RPC("blood",RPCMode.AllBuffered);
if(!chase.isPlaying)
{
chase.Play();
}

if(count >= 5)
{
fadeOut();
count = 0;
}
count++;

if(escapeCounter >= 550)
{
networking.SendMessage("EscapeFish");
escapeCounter = 0;
health = 100;
networkView.RPC("bloodoff",RPCMode.AllBuffered);
chase.Stop();
}
escapeCounter++;
}

if(health <= 0)
{
networking.SendMessage("DeadFish");
Network.CloseConnection(Network.connections[0], true);
}
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

@RPC
function bloodoff(){
bloodstream.Stop();
}