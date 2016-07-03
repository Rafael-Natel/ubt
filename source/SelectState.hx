package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxSprite;

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

	public function new(player:PlayerConfig) {
		_player = player;

		super();
	}

	override public function create():Void {
		_base = new FlxSprite();
		_base.loadGraphic("assets/art/TelaVersus.png");
		add(_base);

		setupBackBtn();

		setupChar1Btn();
		setupChar2Btn();
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

	private function fadeAndStart() {
		FlxG.cameras.fade(FlxColor.BLACK, 1, false, function() {
			FlxG.switchState(new PlayState());
		});
	}

	override public function update(elapsed:Float):Void
	{
		// var recvData:Bytes = _connection.input.readAll();
		// 	var recvString:String = recvData.toString();

		// 	var statusMessage:StatusMessage = Json.parse(recvString);

		// 	if (statusMessage.code == ESUCCESS) {
		// 		return true;
		// 	}
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
				fadeAndStart();
			}
		}

		super.update(elapsed);
	}
}
