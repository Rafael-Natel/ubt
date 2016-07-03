

enum StatusCode {
	ENOTHING;
	ESUCCESS;
	ETOOMANYPLAYERS;
	ESELECT;
}


typedef StatusMessage = {
	var status:String;
	var code:StatusCode;
}
