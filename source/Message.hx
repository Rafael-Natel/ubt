


typedef StatusMessage = {
	var status:String;
	var code:UInt;
}

typedef SelectMessage = {
	var status:String;
	var code:UInt;

	var player:String;
	var character:String;
}

typedef ConnectMessage = {
	var status:String;
	var code:UInt;
	var left:Bool;
}

typedef PlayerInfo = {
	var x:Float;
	var y:Float;
	var action:String;
}
