package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.util.FlxCollision;
import flixel.ui.FlxBar;
using flixel.util.FlxSpriteUtil;

import PlayerConfig;

class PlayState extends FlxState
{
	private var _baseY:Float;	// this is the starting Y position of our guy, we will use this to make the guy float up and down
	private var _ground:FlxTileblock;
	private var _playerConfig:PlayerConfig;
	private var _playerConfigOther:PlayerConfig;

	private var _serverIpAddr = "localhost";
	private var _remoteConnection:sys.net.Socket;

	public var player1:FlxSprite;
	public var player2:FlxSprite;
	private var _sprPlayer:Player;
	private var _base:FlxSprite;
	private var _healthBar:FlxBar;
    var numCollisions:Int = 0;

	public function new(player:PlayerConfig, otherPlayer:PlayerConfig, serverIp:String) {
		super();

		_playerConfig = player;
		_playerConfigOther = otherPlayer;
		_serverIpAddr = serverIp;
	}

	override public function create():Void
	{

        _base = new FlxSprite();
		_base.loadGraphic("assets/art/Cenario.png");
		add(_base);

        _healthBar = new FlxBar(2, 2, FlxBarFillDirection.LEFT_TO_RIGHT, 600, 60, _sprPlayer, "health", 0, 100, true);
		_healthBar.createGradientBar([0xcc111111], [0xffff0000, 0xff00ff00], 1, 0, true, 0xcc333333);
		_healthBar.scrollFactor.set();
		add(_healthBar);

		// a tileblock of ground tiles - will move with the player
		_ground = new FlxTileblock(0, FlxG.height - 64, FlxG.width * 4, 64);
		_ground.loadTiles("assets/art/chao1.png", 1278, 200);
		add(_ground);

		trace("You are ", _playerConfig.getCharacter());
		trace("Enemy is ", _playerConfigOther.getCharacter());

		try {
			_remoteConnection = new sys.net.Socket();
			_remoteConnection.connect(new sys.net.Host(_serverIpAddr), 5000);

			_playerConfigOther.setConnection(_remoteConnection);

			sendRemotePlayerInfo();
		} catch(msg:String) {
			trace("ERROR", msg);
		}

		if (_playerConfig.isLeft()) {
			addLeftPlayer(_playerConfig);
			addRightRemote(_playerConfigOther);
		} else {
			addLeftRemote(_playerConfigOther);
			addRightPlayer(_playerConfig);
		}

		super.create();
	}

    private function sendRemotePlayerInfo() {
		var data:String = '{"player": "' + _playerConfigOther.getName() + '", "action": "getinfo"}';
		try {
			_remoteConnection.write(data + "\n");
		} catch(msg:String) {
			trace("ERROR", msg);
		}
	}

	private function addLeftPlayer(player:PlayerConfig) {
		if (player.getCharacter() == "max") {
			player1 = new MaxPlayer(300, 200, RIGHT, player.getConnection());
		} else {
			player1 = new DraxPlayer(300, 200, RIGHT, player.getConnection());
		}

		add(player1);
	}

	private function addRightPlayer(player:PlayerConfig) {
		if (player.getCharacter() == "max") {
			player2 = new MaxPlayer(600, 200, LEFT, player.getConnection());
		} else {
			player2 = new DraxPlayer(600, 200, LEFT, player.getConnection());
		}

		add(player2);
	}

	private function addLeftRemote(player:PlayerConfig) {
		if (player.getCharacter() == "max") {
			player1 = new MaxRemote(300, 200, RIGHT, player.getConnection());
		} else {
			player1 = new DraxRemote(300, 200, RIGHT, player.getConnection());
		}

		add(player1);
	}

	private function addRightRemote(player:PlayerConfig) {
		if (player.getCharacter() == "max") {
			player2 = new MaxRemote(600, 200, LEFT, player.getConnection());
		} else {
			player2 = new DraxRemote(600, 200, LEFT, player.getConnection());
		}

		add(player2);
	}

	override public function update(elapsed:Float):Void
	{

        numCollisions = 0;
        if(FlxCollision.pixelPerfectCheck(player1,player2) == true) {
            FlxObject.separate(player1,player2);
            trace("Collide");
        }
		FlxG.collide(player1, _ground);
		FlxG.collide(player2, _ground);


		super.update(elapsed);
    }

	}
