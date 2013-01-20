function OnTriggerEnter(){
Debug.Log("Hello");
var newCol:Vector3 = Vector3(1,0,0);
networkView.RPC("SetColor",RPCMode.AllBuffered,newCol);
}

@RPC
function SetColor(newColor:Vector3){
renderer.material.color = Color(newColor.x,newColor.y,newColor.z,1);
}