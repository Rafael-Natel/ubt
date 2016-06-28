package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxCollision;
using flixel.util.FlxSpriteUtil;
class PlayState extends FlxState
{

    
	private var _baseY:Float;	// this is the starting Y position of our guy, we will use this to make the guy float up and down
	private var _flakes:FlxTypedGroup<Flake>; // a group of flakes
	private var _vPad:FlxVirtualPad;
	private var _ground:FlxTileblock;
	private var _healthBar:FlxBar;
	public var player:Player;
	public var enemy:Enemy;
	private var _sprPlayer:Player;
	private var _base:FlxSprite;
    var numCollisions:Int = 0;

	override public function create():Void
	{
        
        _base = new FlxSprite();
		_base.loadGraphic("assets/art/Cenario.png");
		add(_base);

		// a tileblock of ground tiles - will move with the player
		_ground = new FlxTileblock(0, FlxG.height - 64, FlxG.width * 4, 64);
		_ground.loadTiles("assets/art/chao.png", 1278, 200);
		add(_ground);

		_healthBar = new FlxBar(2, 2, FlxBarFillDirection.LEFT_TO_RIGHT, 90, 6, _sprPlayer, "health", 0, 10, true);
		_healthBar.createGradientBar([0xcc111111], [0xffff0000, 0xff00ff00], 1, 0, true, 0xcc333333);
		_healthBar.scrollFactor.set();
		add(_healthBar);

		var shine:FlxSprite = FlxGradient.createGradientFlxSprite(
			Std.int(_healthBar.width), Std.int(_healthBar.height),
			[0x66ffffff, 0xffffffff, 0x66ffffff, 0x11ffffff, 0x0]);
		shine.alpha = .5;
		shine.x = _healthBar.x;
		shine.y = _healthBar.y;
		shine.scrollFactor.set();
		add(shine);

		// our guy for the player to move
		add(player = new Player(300, 200, RIGHT));
        
		// Set up our camera to follow the guy, and stay within the confines of our 'world'
		FlxG.camera.follow(player);
		FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);

		super.create();
	}
    
	override public function update(elapsed:Float):Void
	{
		numCollisions = 0;
		FlxG.collide(player, _ground);
		FlxG.collide(player, enemy);
		super.update(elapsed);

		if  (FlxG.collide(player, enemy))
		{FlxG.sound.play("assets/sounds/swordHead" + Reg.SoundExtension, 1, false);}

	}
}
