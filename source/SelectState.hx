package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxSprite;

import haxe.io.Bytes;
import haxe.Json;

import Message;

class SelectState extends FlxState {
	private var _backText:FlxText;
	private var _pointer:FlxSprite;
	private var _base:FlxSprite;
	private var _char1Sprite:FlxSprite;
	private var _char2Sprite:FlxSprite;

	private var _charWidth = 150;
	private var _charHeight = 180;

	private var _isBack:Bool;
	private var _currentChar:Bool; // true == char1, false == char2;

	private var _player:PlayerConfig;

	private var _errText:FlxText;
	private var _waitingPlayers:Bool;


	public function new(player:PlayerConfig) {
		_player = player;

		super();
	}

	override public function create():Void {
		_base = new FlxSprite();
		_base.loadGraphic("assets/art/TelaVersus.png");
		add(_base);

		_errText = new FlxText((FlxG.width/2)-200, 30, "Waiting for player2... ");
		_errText.color = 0xFFCC00;
		_errText.size = 25;
		_errText.antialiasing = true;

		setupBackBtn();

		setupChar1Btn();
		setupChar2Btn();

		_currentChar = true;
	}

	private function setupBackBtn() {
		// Add a button which will take us back to the main menu state
		_backText = new FlxText(50, 50, 0, "Back");
		_backText.color = 0xFFCC00;
		_backText.size = 25;
		_backText.antialiasing = true;

		add(_backText);

		_pointer = new FlxSprite();
		_pointer.loadGraphic("assets/art/pointer.png");
		_pointer.x = _backText.x - _pointer.width - 15;
		add(_pointer);
	}

	private function setupChar1Btn() {
		var x = 5;
		var y = 100;

		_char1Sprite = new FlxSprite(x, y);
		_char1Sprite.loadGraphic("assets/art/Max.png");
		add(_char1Sprite);
	}

	private function setupChar2Btn() {
		var x = FlxG.width/2 + 100;
		var y = 100;

		_char2Sprite = new FlxSprite(x, y);
		_char2Sprite.loadGraphic("assets/art/Drax.png");

		add(_char2Sprite);
	}

	private function gotoBack() {
		FlxG.cameras.fade(FlxColor.BLACK, 1, false, function() {
			FlxG.switchState(new MenuState());
		});
	}

	private function waitForPlayers() {
		_waitingPlayers = true;

		var connection = _player.getConnection();
		connection.write('{"action": "waitForPlayers", "player": "' + _player.getName() + '"}');

		var recvData:String = connection.input.readLine();

		trace("got", recvData);

		var selected:SelectMessage = Json.parse(recvData);

		if (selected.code == 4) {
			trace("NOT READY YET...", selected.status);

			return;
		}

		_waitingPlayers = false;

		trace("WE'RE READY TO PLAY");
		trace("Name: ", selected.player);
		trace("Character: ", selected.character);

		var player2:PlayerConfig = new PlayerConfig("player2");
		player2.setCharacter(selected.character);

		FlxG.cameras.fade(FlxColor.BLACK, 1, false, function() {
			FlxG.switchState(new PlayState(_player, player2));
		});
	}

	private function sendSelectChar() {
		var characterName:String;

		if (_currentChar) {
			characterName = "max";
		} else {
			characterName = "drax";
		}

		var dataMessage:String = '{"player": "' + _player.getName() + '", "character": "' + characterName + '"}';

		var connection = _player.getConnection();

		try {
			connection.write(dataMessage+"\n");

			trace("Selection of ", characterName, " sent");

			add(_errText);

			var recvData:String = connection.input.readLine();

			trace("got", recvData);

			var status:StatusMessage = Json.parse(recvData);

			if (status.code == 1) {
				waitForPlayers();
			} else {
				trace("ERROR", status.status);
			}
		} catch(msg:String) {
			trace("ERROR:", msg);
		}
	}

	override public function update(elapsed:Float):Void
	{
		if (_waitingPlayers) {
			waitForPlayers();
			super.update(elapsed);
			return;
		}


		if (_isBack) {
			_pointer.y = _backText.y + 10;
		} else {
			_pointer.y = -10;
		}

		if (_currentChar) {
			_char1Sprite.loadGraphic("assets/art/player1SelectMax.png");
			_char2Sprite.loadGraphic("assets/art/Drax.png");
		} else {
			_char1Sprite.loadGraphic("assets/art/Max.png");
			_char2Sprite.loadGraphic("assets/art/player1SelectDrax.png");
		}

		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) {
			_isBack = !_isBack;
		}

		if (!_isBack && (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)) {
			_currentChar = !_currentChar;
		}

		if (FlxG.keys.anyJustPressed([SPACE, ENTER, C])) {
			if (_isBack) {
				gotoBack();
			} else {
				sendSelectChar();
			}
		}

		super.update(elapsed);
	}
}
