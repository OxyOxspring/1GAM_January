#pragma strict

private var health:int;
var bloodstream:ParticleSystem;
var chomp:AudioSource;

function OnTriggerEnter(object:Collider){

if(object.gameObject.name == "EvilFish(Clone)")
{
health -= 20;
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

@RPC
function blood(){
bloodstream.Play();
}