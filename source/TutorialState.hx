package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flash.system.System;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;

class SelectState extends FlxState 
{

	private var _telaSelect:FlxSprite;
	
	override public function create():Void 
	{
		var skipSplash:Bool=true;

		_telaSelect = new FlxSprite();
		_telaSelect.loadGraphic("assets/art/menuTutorial.png");
		add(_telaSelect);

		FlxG.sound.play("assets/sounds/musicMenu" + Reg.SoundExtension, 1, true);
		super.create();
	}
	
}