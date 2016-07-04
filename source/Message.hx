


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

typedef KeyMessage = {
	var key:String;
}
