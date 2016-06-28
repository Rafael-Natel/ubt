package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.util.FlxCollision;
using flixel.util.FlxSpriteUtil;
class PlayState extends FlxState
{


	private var _baseY:Float;	// this is the starting Y position of our guy, we will use this to make the guy float up and down
	private var _ground:FlxTileblock;
	public var player1:Player;
	public var player2:Player2;
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
		_ground.loadTiles("assets/art/chao1.png", 1278, 200);
		add(_ground);

		add(player1 = new Player(300, 200, RIGHT));
		add(player2 = new Player2(600, 200, LEFT));

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		numCollisions = 0;
		FlxG.collide(player1, _ground);
		FlxG.collide(player2, _ground);

		FlxG.collide(player1, player2);

		super.update(elapsed);
    }

	}

