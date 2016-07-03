
enum Character {
	Max;
	Drax;
}

class PlayerConfig {
	private var _name:String;
	private var _character:Character;
	private var _connection:sys.net.Socket;

	public function new(playerName:String) {
		_name = playerName;
	}

	public function setCharacter(char:Character) {
		_character = char;
	}

	public function setConnection(conn:sys.net.Socket) {
		_connection = conn;
	}

	public function setName(name:String) {
		_name = name;
	}
}
