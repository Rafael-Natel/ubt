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
	var numCollisions:Int = 0;

	override public function create():Void
	{
		// build a gradient sky for the background - make it as big as our screen, and, it's going to be stationary
		var sky:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff6dcff6, 0xff333333], 16);
		sky.scrollFactor.set();
		add(sky);

		var uncoloredMountain:FlxSprite = new FlxSprite(0, 0, "assets/art/mountainsneve.png");
		var uncoloredClouds:FlxSprite = new FlxSprite(0, 0, "assets/art/clouds.png");

		add(spawnCloud(0)); // add a cloud layer to go behind everything else

		// we're going to have 6 mountain layers with a cloud layer on top.
		for (i in 0...6)
		{
			add(spawnMountain(i));
			add(spawnCloud(i));
		}

		// this is just a solid-gradient to go behind our ground
		var _sprSolid = FlxGradient.createGradientFlxSprite(FlxG.width, 64, [0xff333333, 0xff000000], 8);
		_sprSolid.y = FlxG.height - 64;
		_sprSolid.scrollFactor.set();
		add(_sprSolid);

		// a tileblock of stuff to go between the player and the mountains
		var _spookyStuff = new FlxTileblock(0, FlxG.height - 128, Math.ceil(FlxG.width * 4), 64);
		_spookyStuff.loadTiles("assets/art/spookystuff.png", 64, 64, 4);
		_spookyStuff.scrollFactor.set(.95, 0);
		add(_spookyStuff);

		// a tileblock of ground tiles - will move with the player
		_ground = new FlxTileblock(0, FlxG.height - 64, FlxG.width * 4, 64);
		_ground.loadTiles("assets/art/tiles.png", 16, 16, 1);
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
		add(player = new Player(300, 0, RIGHT));


		var txtInst:FlxText = new FlxText(0, FlxG.height - 16, FlxG.width, "Left/Right to Move | K to Punch");
		txtInst.alignment = FlxTextAlign.CENTER;
		txtInst.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xff333333, 1, 1);
		txtInst.scrollFactor.set();
		add(txtInst);

		// we're going to have some snow or ash flakes drifting down at different 'levels'. We need a lot of them for the effect to work nicely
		_flakes = new FlxTypedGroup<Flake>();
		add(_flakes);

		for (i in 0...1000)
		{
			_flakes.add(new Flake(i % 10));
		}


		// add some tweens to fade the player in and out and to make him 'float' up and down

		#if (mobile)
		_vPad = new FlxVirtualPad(FlxDPadMode.LEFT_RIGHT, FlxActionMode.NONE);
		add(_vPad);
		#end


		// Set up our camera to follow the guy, and stay within the confines of our 'world'
		FlxG.camera.follow(player);
		FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);

		super.create();
	}

	/**
	 * This function spawns a new Tileblock of clouds which will be positioned near the top of the screen
	 */
	private function spawnCloud(Pos:Int):FlxTileblock
	{
		var clouds:FlxTileblock = new FlxTileblock(0, 0, Math.ceil(FlxG.width * 4), 64);
		clouds.x += -8 + Math.floor(FlxG.random.float( 1, 8) * 4);
		clouds.y += 50 +  Math.floor(FlxG.random.float( 1, 8) * Pos);
		clouds.loadTiles(bakeColors(FlxColor.WHITE.getDarkened(.6 - ( (Pos * .1))),"assets/art/clouds.png", (1 - (.2 + (Pos * .1) * .5))), 64, 64, Pos * 5);
		clouds.scrollFactor.set(.2 + (Pos * .1) + .05, 0);
		return clouds;
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

	/**
	 * This function generates and returns a new FlxTileblock using our mountain sprites.
	 */
	private function spawnMountain(Pos:Int):FlxTileblock
	{
		var mountain:FlxTileblock = new FlxTileblock(0, FlxG.height - (180 + ((5 - Pos) * 16)) , Math.ceil(FlxG.width * 4), 116);
		mountain.loadTiles(bakeColors(FlxColor.WHITE.getDarkened(1 - (.2 + (Pos * .1))), "assets/art/mountainsneve.png"), 256, 116, 0);
		mountain.scrollFactor.set(.2 + (Pos * .1), 0);
		return mountain;
	}

	private function bakeColors(color:FlxColor, asset:String, ?alpha:Float = 1):String
	{
		var bmpData:BitmapData = FlxG.bitmap.get(asset).bitmap.clone();

		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.redMultiplier = color.redFloat;
		colorTransform.greenMultiplier = color.greenFloat;
		colorTransform.blueMultiplier = color.blueFloat;
		colorTransform.alphaMultiplier = alpha;

		bmpData.colorTransform(bmpData.rect, colorTransform);
		var key:String = asset + "_color=" + color;
		FlxG.bitmap.add(bmpData,false, key);
		return key;



	}
}
