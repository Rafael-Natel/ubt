
class PlayerConfig {
	private var _name:String;
	private var _character:String;
	private var _connection:sys.net.Socket;
	private var _isLeft:Bool;

	public function new(playerName:String) {
		_name = playerName;
	}

	public function setCharacter(char:String) {
		_character = char;
	}

	public function setConnection(conn:sys.net.Socket) {
		_connection = conn;
	}

	public function setName(name:String) {
		_name = name;
	}

	public function setIsLeft(l:Bool) {
		return _isLeft;
	}

	public function getName():String {
		return _name;
	}

	public function getConnection():sys.net.Socket {
		return _connection;
	}

	public function getCharacter():String {
		return _character;
	}

	public function isLeft():Bool {
		return _isLeft;
	}
}
