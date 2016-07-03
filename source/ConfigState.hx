package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flash.system.System;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.addons.ui.FlxInputText;
import haxe.io.Bytes;
import haxe.Json;

import Message;
import PlayerConfig;

enum Option
{
	INPUT_SERVER;
	INPUT_NAME;
	CONNECT;
	BACK;
}

class ConfigState extends FlxState
{
	private var _serverText:FlxText;
	private var _playerText:FlxText;
	private var _connectText:FlxText;
	private var _backText:FlxText;

	private var _pointer:FlxSprite;
	private var _base:FlxSprite;

	// This will indicate what the pointer is pointing at
	private var _option:Option = CONNECT;

	private var _menuChangeSound = "assets/sounds/sword1";
	private var _menuFireSound   = "assets/sounds/sword1";

	private var _serverIpInput:FlxInputText;
	private var _playerInput:FlxInputText;

	private var _connection:sys.net.Socket;

	private var _playerName = "";
	private var _serverIpAddr = "localhost";

	private var _player:PlayerConfig;

	override public function create():Void
	{
		var skipSplash:Bool=true;

		_base = new FlxSprite();
		_base.loadGraphic("assets/art/IpTela.png");
		add(_base);

		_serverText = new FlxText((FlxG.width/2)-200, (FlxG.height/2)-100, "Server IP: ");
		add(_serverText);

		_serverIpInput = new FlxInputText(_serverText.x + 180, _serverText.y+8, 150, _serverIpAddr, 12);
		_serverIpInput.callback = getserverip;
		add(_serverIpInput);

		_playerText = new FlxText(_serverText.x, _serverText.y+30, "Nickname: ");
		add(_playerText);
		_playerInput = new FlxInputText(_playerText.x + 180, _playerText.y+8, 150, "", 12);
		_playerInput.callback = getplayername;
		add(_playerInput);

		_connectText = new FlxText(FlxG.width * 2.5 / 3, FlxG.height * 2.5 / 3, 0, "Connect");
		_backText = new FlxText(FlxG.width * 2.5 / 3, FlxG.height * 2.5 / 3 + 30, 0, "Back");

		_connectText.color = _backText.color = _serverText.color = _playerText.color = 0xFFCC00;
		_connectText.size = _backText.size = _playerText.size = _serverText.size = 25;
		_connectText.antialiasing = _backText.antialiasing = _playerText.antialiasing = _serverText.antialiasing = true;

		//		_playText.font = "assets/fonts/fight1.ttf";
		//_tutorialText.font = "assets/fonts/fight1.ttf";
		//_exitText.font = "assets/fonts/fight1.ttf";

		add(_connectText);
		add(_backText);

		_pointer = new FlxSprite();
		_pointer.loadGraphic("assets/art/pointer.png");
		_pointer.x = _connectText.x - _pointer.width - 15;
		add(_pointer);

		FlxG.sound.play("assets/sounds/musicMenu" + Reg.SoundExtension, 1, true);
		super.create();
	}

    private function getserverip(ip:String, b:String) {
		 trace("A", ip);

		 _serverIpAddr = ip;
	 }

	private function getplayername(name:String, b:String) {
		 trace("A", name);

		 _playerName = name;
	 }

	override public function update(elapsed:Float):Void
	{
		_pointer.y = switch (_option)
		{
			case CONNECT: _connectText.y + 10;
			case BACK: _backText.y + 10;
			case INPUT_SERVER: _serverText.y + 10;
			case INPUT_NAME: _playerText.y + 10;
		}

		if (FlxG.keys.justPressed.UP)
			modifySelectedOption(-1);
		if (FlxG.keys.justPressed.DOWN)
			modifySelectedOption(1);

		if (FlxG.keys.anyJustPressed([SPACE, ENTER, C]))
		{
			switch (_option)
			{
				case CONNECT:
					FlxG.sound.play(_menuFireSound + Reg.SoundExtension, 1, false);
					verifyAndGo();
				case BACK:
					FlxG.sound.play(_menuFireSound + Reg.SoundExtension, 1, false);
					FlxG.cameras.fade(0xff969867, 1, false, backToMenu);
				case INPUT_SERVER:
					_option = CONNECT;
				case INPUT_NAME:
					_option = CONNECT;
			}
		}

		super.update(elapsed);
	}

	private function modifySelectedOption(modifier:Int):Void
	{
		var options = Option.getConstructors();
		var index = options.indexOf(Std.string(_option)) + modifier;
		_option = Option.createByIndex(FlxMath.wrap(index, 0, options.length - 1));

		if (_option == INPUT_SERVER) {
			_serverIpInput.hasFocus = true;
			_playerInput.hasFocus = false;
		} else if (_option == INPUT_NAME) {
			_playerInput.hasFocus = true;
			_serverIpInput.hasFocus = false;
		}

		FlxG.sound.play(_menuChangeSound + Reg.SoundExtension, 1, false);
	}

	private function backToMenu():Void {
		FlxG.switchState(new MenuState());										   }

	private function sendPlayer():Bool {
		if (_playerName == "") {
			return false;
		}

	    var data:String = '{"name": "' + _playerName + '"}';

		try {
			_connection.write(data+"\n");
			return true;
		} catch( msg : String ) {
			trace("Error occurred: " + msg);
		}

		return false;
	}

	private function goNext() {
		_player = new PlayerConfig(_playerName);
		_player.setConnection(_connection);

		FlxG.switchState(new SelectState(_player));
	}

    private function verifyAndGo():Void {
		if (testConnection()) {
			FlxG.cameras.fade(0xff969867, 1, false, goNext);
		} else {
			// Show error message to user?
		}
	}

	private function testConnection():Bool {
		try {
			if (_connection == null) {
				_connection = new sys.net.Socket();
				_connection.connect(new sys.net.Host(_serverIpAddr),5000);
			}

			if (sendPlayer()) {
				return true;
			} else {
				trace("Failed to send player name");
			}
		} catch( msg : String ) {
			trace("Error occurred: " + msg);
		}

		return false;
	}
}
