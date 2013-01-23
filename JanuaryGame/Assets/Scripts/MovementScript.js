private var health:int;

function Start () {
health = 100;
}

function Update () {
if(networkView.isMine){
Debug.Log(health);
}
else{
enabled = false;
}
}

function OnTriggerEnter(){
var newCol:Vector3 = Vector3(1,0,0);
networkView.RPC("SetColor",RPCMode.AllBuffered,newCol);
}

@RPC
function SetColor(newColor:Vector3){
health -= 10;
renderer.material.color = Color(newColor.x,newColor.y,newColor.z,1);
}