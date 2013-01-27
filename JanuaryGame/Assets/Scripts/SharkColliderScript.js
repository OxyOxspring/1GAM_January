

private var health:int;
var chomp:AudioSource;
private var count:int;

function OnTriggerEnter(object:Collider){

if(object.transform.parent.gameObject.name == "GoodFish(Clone)")
{
if(networkView.isMine)
{
health += 25;
if(health >= 100)
{
health = 100;
}
fadeOut();
chomp.Play();
}
}

}


function Start () {
health = 100;
count = 0;
}

function Update () {
if(networkView.isMine){
if(count >= 120)
{
health --;
count = 0;
}
count ++;
}

if(health <= 0)
{
Network.Disconnect();
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
	var stringy:String= "";
	stringy = "Current Hunger: " + health;
	GUI.Label(Rect(Screen.width - 160, 30, 150,50), stringy);
	
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



