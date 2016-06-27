package;

import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;

enum State {
	LEFT;
	RIGHT;
	IDLE_LEFT;
	IDLE_RIGHT;
	PUNCH_LEFT;
	PUNCH_RIGHT;
    PUNCHSTRONG_RIGHT;
    PUNCHSTRONG_LEFT;
    GUARD_RIGHT;
    GUARD_LEFT;
}

/**
 * ...
 * @author David Bell
 */
class Player extends FlxSprite
{
	public static inline var RUN_SPEED:Int = 90;
	public static inline var GRAVITY:Int = 440;
	public static inline var JUMP_SPEED:Int = 500;
	public static inline var BULLET_SPEED:Int = 200;
	public static inline var GUN_DELAY:Float = 0.4;


	private var _parent:PlayState;
	private var _state:State;

	public function new(X:Int, Y:Int, state:State)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		_state = state;

		//Set up the graphics
		loadGraphic("assets/art/sprite25.png", true, 354, 449);

		animation.add("walking-right", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 12, false);
        animation.add("walking-left", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], 12, false);
		animation.add("idle-right", [0]);
		animation.add("idle-left", [15]);
		animation.add("guard-right", [28, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40], false);
  		animation.add("guard-left", [41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51], false);
		animation.add("lose-left", [52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71], false);//20
        animation.add("lose-right", [72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92], false);
        animation.add("punch-strong-right", [92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112], false);//112
        animation.add("punch-strong-left", [113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131], false);//131
		animation.add("punch-right", [132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161], 40, false);//161
        animation.add("punch-left", [162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191], 40, false);//191
        animation.add("jump-left", [192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212], false);//212
        animation.add("jump-right", [213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230,231, 232, 233, 234], false);//234
        animation.add("jump-kick-right", [235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253], false);//253
        animation.add("jump-kick-left", [254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273], false);//273
        animation.add("jumb-sword-left", [274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287,288, 289, 290, 291, 292, 293], false);//293
        animation.add("jump-sword-right", [294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313], false);//313

		animation.callback = function(name:String, frameNum:Int, frameIndex:Int) {
			trace("Name: ", name, ", frameNum: ", frameNum, ", frameIndex: ", frameIndex);
		};

		drag.set(RUN_SPEED * 10, RUN_SPEED * 10);
		maxVelocity.set(RUN_SPEED, JUMP_SPEED);
		acceleration.y = GRAVITY;
		//setSize(500, 100);
		offset.set(3, 4);

	}

	public override function update(elapsed:Float):Void
	{
		if (_state != LEFT && _state != RIGHT &&
		_state != IDLE_LEFT && _state != IDLE_RIGHT) {
			if (!animation.finished) {
				super.update(elapsed);
				return;
			}
		}

		// Reset to 0 when no button is pushed
		acceleration.x = 0;

		if (FlxG.keys.anyPressed([LEFT]))
		{
			acceleration.x = -drag.x;
		}
		else if (FlxG.keys.anyPressed([RIGHT]))
		{
			acceleration.x = drag.x;
		}

		jump(elapsed);

		// Animations
		if (velocity.x > 0) {
			_state = RIGHT;
			animation.play("walking-right");
		} else if (velocity.x < 0) {
			_state = LEFT;
			animation.play("walking-left");
        } else if (velocity.x == 0){
            if (_state == RIGHT || _state == IDLE_RIGHT) {
				_state = IDLE_RIGHT;
				animation.play("idle-right");
			} else {
				_state = IDLE_LEFT;
				animation.play("idle-left");
            }
		  }

		if (FlxG.keys.anyPressed([A])) {
			if (_state == RIGHT || _state == IDLE_RIGHT) {
				_state = PUNCH_RIGHT;
				animation.play("punch-right");
			} else {
				_state = PUNCH_LEFT;
				animation.play("punch-left");
			 }
        }
        if (FlxG.keys.anyPressed([S])) {
            if (_state == RIGHT || _state == IDLE_RIGHT) {
                _state = PUNCHSTRONG_RIGHT;
                animation.play("punch-strong-right");
             } else {
                    _state = PUNCHSTRONG_LEFT;
                    animation.play("punch-strong-left");
             }
        }

        if (FlxG.keys.anyPressed([D])) {
            if (_state == RIGHT || _state == IDLE_RIGHT) {
                _state = GUARD_RIGHT;
                animation.play("guard-right");
            } else {
                _state = GUARD_LEFT;
                animation.play("guard-left");
            }
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

		super.update(elapsed);
	}

	private function jump(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed([SPACE]))
		{
			if ((velocity.y == 0)) {
				//FlxG.sound.play("assets/sounds/jump" + Reg.SoundExtension, 1, false);
				velocity.y = - 0.6 * maxVelocity.y;
			}
		}
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
