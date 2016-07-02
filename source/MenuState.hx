package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flash.system.System;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;

enum Option
{
	PLAY;
	TUTORIAL;
	EXIT;
}

class MenuState extends FlxState
{
	private var _playText:FlxText;
	private var _tutorialText:FlxText;
	private var _exitText:FlxText;

	private var _pointer:FlxSprite;
	private var _base:FlxSprite;

	// This will indicate what the pointer is pointing at
	private var _option:Option = PLAY;

	private var _menuChangeSound = "assets/sounds/sword1";
	private var _menuFireSound   = "assets/sounds/sword1";

	override public function create():Void
	{
		var skipSplash:Bool=true;

		_base = new FlxSprite();
		_base.loadGraphic("assets/art/menu.png");
		add(_base);

		_playText = new FlxText(FlxG.width * 2.5 / 3, FlxG.height * 2.5 / 3, 0, "Play");
		_tutorialText = new FlxText(FlxG.width * 2.5 / 3, FlxG.height * 2.5 / 3 + 30, 0, "Tutorial");
		_exitText = new FlxText(FlxG.width * 2.5 / 3, FlxG.height * 2.5 / 3 + 60, 0, "Exit");

		_playText.color = _tutorialText.color = _exitText.color = 0xFFCC00;
		_playText.size = _tutorialText.size = _exitText.size = 25;
		_playText.antialiasing = _tutorialText.antialiasing = _exitText.antialiasing = true;

		//		_playText.font = "assets/fonts/fight1.ttf";
		//_tutorialText.font = "assets/fonts/fight1.ttf";
		//_exitText.font = "assets/fonts/fight1.ttf";

		add(_playText);
		add(_tutorialText);
		add(_exitText);

		_pointer = new FlxSprite();
		_pointer.loadGraphic("assets/art/pointer.png");
		_pointer.x = _playText.x - _pointer.width - 15;
		add(_pointer);

		FlxG.sound.play("assets/sounds/musicMenu" + Reg.SoundExtension, 1, true);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		_pointer.y = switch (_option)
		{
			case PLAY: _playText.y+10;
			case TUTORIAL: _tutorialText.y+10;
			case EXIT: _exitText.y+10;
		}

		if (FlxG.keys.justPressed.UP)
			modifySelectedOption(-1);
		if (FlxG.keys.justPressed.DOWN)
			modifySelectedOption(1);

		if (FlxG.keys.anyJustPressed([SPACE, ENTER, C]))
		{
			switch (_option)
			{
				case PLAY:
					FlxG.sound.play(_menuFireSound + Reg.SoundExtension, 1, false);
					FlxG.cameras.fade(0xff969867, 1, false, startGame);
				case TUTORIAL:

				case EXIT:
					System.exit(0);
			}
		}

		super.update(elapsed);
	}

	private function modifySelectedOption(modifier:Int):Void
	{
		var options = Option.getConstructors();
		var index = options.indexOf(Std.string(_option)) + modifier;
		_option = Option.createByIndex(FlxMath.wrap(index, 0, options.length - 1));

		FlxG.sound.play(_menuChangeSound + Reg.SoundExtension, 1, false);
	}

	private function startGame():Void
	{
		FlxG.switchState(new SelectState());
	}
}
