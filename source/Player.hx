package;

import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 */
class Player extends FlxSprite
{
	public static inline var RUN_SPEED:Int = 90;
	public static inline var GRAVITY:Int = 440;
	public static inline var JUMP_SPEED:Int = 250;
	public static inline var JUMPS_ALLOWED:Int = 2;
	public static inline var BULLET_SPEED:Int = 200;
	public static inline var GUN_DELAY:Float = 0.4;


	private var _parent:PlayState;

	private var _jumpTime:Float = -1;
	private var _timesJumped:Int = 0;
	private var _jumpKeys:Array<FlxKey> = [C, SPACE];

	private var _xgridleft:Int = 0;
	private var _xgridright:Int = 0;
	private var _ygrid:Int = 0;

	public var climbing:Bool = false;
	private var _onLadder:Bool = false;

	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		//Set up the graphics
		loadGraphic("assets/art/SpritePlayer.png", true, 248, 495);

		animation.add("walking", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 12, true);
		animation.add("idle", [0]);
		animation.add("jump", [5]);
		animation.add("punch", [8]);


		drag.set(RUN_SPEED * 10, RUN_SPEED * 10);
		maxVelocity.set(RUN_SPEED, JUMP_SPEED);
		acceleration.y = GRAVITY;
		//setSize(500, 100);
		offset.set(3, 4);

	}

	public override function update(elapsed:Float):Void
	{
		// Reset to 0 when no button is pushed
		acceleration.x = 0;

		if (climbing)
		{
			// Stop falling if you're climbing a ladder
			acceleration.y = 0;
		}
		else
		{
			acceleration.y = GRAVITY;
		}

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			flipX = true;
			acceleration.x = -drag.x;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			flipX = false;
			acceleration.x = drag.x;
		}

		jump(elapsed);

		// Can only climb when not jumping
		if (_jumpTime < 0)
		{
			climb();
		}

		// Shooting

		// Animations
		if (velocity.x > 0 || velocity.x < 0)
		{
			animation.play("walking");
		}
		else if (velocity.x == 0)
		{
			animation.play("idle");
		}
		if (FlxG.keys.anyPressed([K]))
		{
			animation.play("punch");
		}
		if (velocity.y < 0)
		{
			animation.play("jump");
		}
		if (this.x > 740){
			this.x = 739;
		}
		if (this.x <= 1){
			this.x = 2;
		}
		if (this.y > 450){
			this.y = 450;
		}

		// Convert pixel positions to grid positions. Std.int and floor are functionally the same,
		_xgridleft = Std.int((x + 3) / 16);
		_xgridright = Std.int((x + width - 3) / 16);
		// but I hear int is faster so let's go with that.
		_ygrid = Std.int((y + height - 1) / 16);



		if (isTouching(FlxObject.FLOOR) && !FlxG.keys.anyPressed(_jumpKeys))
		{
			_jumpTime = -1;
			// Reset the double jump flag
			_timesJumped = 0;
		}

		super.update(elapsed);
	}

	private function climb():Void
	{
		if (FlxG.keys.anyPressed([UP, W]))
		{
			if (_onLadder)
			{
				climbing = true;
				_timesJumped = 0;
			}
		}
		else if (FlxG.keys.anyPressed([DOWN, S]))
		{
			if (_onLadder)
			{
				climbing = true;
				_timesJumped = 0;
			}

			if (climbing)
			{
				velocity.y = RUN_SPEED;
			}
		}
	}

	private function jump(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed(_jumpKeys))
		{
			if ((velocity.y == 0) || (_timesJumped < JUMPS_ALLOWED)) // Only allow two jumps
			{
				//FlxG.sound.play("assets/sounds/jump" + Reg.SoundExtension, 1, false);
				_timesJumped++;
				_jumpTime = 0;
				_onLadder = false;
			}
		}

		// You can also use space or any other key you want
		if ((FlxG.keys.anyPressed(_jumpKeys)) && (_jumpTime >= 0))
		{
			climbing = false;
			_jumpTime += elapsed;

			// You can't jump for more than 0.25 seconds
			if (_jumpTime > 0.25)
			{
				_jumpTime = -1;
			}
			else if (_jumpTime > 0)
			{
				velocity.y = - 0.6 * maxVelocity.y;
			}
		}
		else
			_jumpTime = -1.0;
	}

	override public function kill():Void
	{
		if (!alive)
		{
			return;
		}

		super.kill();

		FlxG.cameras.shake(0.005, 0.35);
		FlxG.cameras.flash(0xffDB3624, 0.35);


		FlxG.sound.play("assets/sounds/death" + Reg.SoundExtension, 1, false);
	}
}
