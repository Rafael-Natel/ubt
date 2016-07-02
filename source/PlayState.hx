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
class PlayState extends FlxState
{


	private var _baseY:Float;	// this is the starting Y position of our guy, we will use this to make the guy float up and down
	private var _ground:FlxTileblock;
	public var player1:Player;
	public var player2:Player;
	private var _sprPlayer:Player;
	private var _base:FlxSprite;
	private var _healthBar:FlxBar;
    var numCollisions:Int = 0;

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

		add(player1 = new Player(300, 200, RIGHT));
		add(player2 = new Player(600, 200, LEFT));

		super.create();
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

