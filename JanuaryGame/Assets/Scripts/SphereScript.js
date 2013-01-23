function OnTriggerEnter(){
var newCol:Vector3 = Vector3(1,0,0);
networkView.RPC("SetColor",RPCMode.AllBuffered,newCol);
}

function OnTriggerExit(){
Debug.Log("Hello");
var newCol:Vector3 = Vector3(0,1,0);
networkView.RPC("SetColor",RPCMode.AllBuffered,newCol);
}

@RPC
function SetColor(newColor:Vector3){
renderer.material.color = Color(newColor.x,newColor.y,newColor.z,1);
}