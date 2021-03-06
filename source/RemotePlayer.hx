package;

import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import haxe.Json;

import Message;
import Player;


class RemotePlayer extends FlxSprite
{
	public static inline var RUN_SPEED:Int = 90;
	public static inline var GRAVITY:Int = 440;

    private var _parent:PlayState;
	private var _state:State;
	private var _connection:sys.net.Socket;
	private var _lastTime:Date;

	public function new(X:Int, Y:Int, state:State, connection:sys.net.Socket)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		_connection = connection;
		_state = state;

		animation.callback = function(name:String, frameNum:Int, frameIndex:Int) {
			trace("Name: ", name, ", frameNum: ", frameNum, ", frameIndex: ", frameIndex);
		};

		drag.set(RUN_SPEED * 10, RUN_SPEED * 10);
		maxVelocity.set(RUN_SPEED, 0);
		acceleration.y = GRAVITY;
		//setSize(500, 100);
		offset.set(3, 4);

		_lastTime = Date.now();

	}

	private function safePositions() {
		if (this.x > 740){
			this.x = 739;
		}
		if (this.x <= 1){
			this.x = 2;
		}
		if (this.y > 450){
			this.y = 450;
		}
	}

	private function handleXMovement():Void {
		if (velocity.x > 0) {
			_state = RIGHT;
			animation.play("walking-right");
		} else if (velocity.x < 0) {
			_state = LEFT;
			animation.play("walking-left");
        } else if (velocity.x == 0){
            if (isRight()) {
				_state = IDLE_RIGHT;
				animation.play("idle-right");
			} else {
				_state = IDLE_LEFT;
				animation.play("idle-left");
            }
		}
	}

	private function sendKeyPressed(key:String) {
		var data:KeyMessage = {
			key: key
		};

		try {
			var dataStr = Json.stringify(data);

			trace("writing data", dataStr);

			_connection.write(dataStr + "\n");
		} catch(msg:String) {
			trace("ERROR:", msg);
		}
	}

	private function getKeyPressed():String {
		var key:String = "";

		try {
			var dataRecv:String = _connection.input.readLine();
			var data:KeyMessage = Json.parse(dataRecv);

			key = data.key;
		} catch(msg:String) {
			trace("ERROR when getting key pressed: ", msg);
		}

		return key;
	}

	public override function update(elapsed:Float):Void
	{
		if (isFighting()) {
			if (!animation.finished) {
				super.update(elapsed);
				return;
			}
		}

		var currentTime:Date = Date.now();

		var key:String = "";

		if (_lastTime.getTime() + 1000 < currentTime.getTime()) {
			key = getKeyPressed();
		}

		// Reset to 0 when no button is pushed
		acceleration.x = 0;

		if (key == "left") {
			acceleration.x = -drag.x;
		}
		else if (key == "right") {
			acceleration.x = drag.x;
		}

		// Animations

		handleXMovement();

		if (key == "A") {
			if (isRight()) {
				_state = PUNCH_RIGHT;
				animation.play("punch-right");
			} else {
				_state = PUNCH_LEFT;
				animation.play("punch-left");
			 }
        }

        if (key == "S") {
            if (isRight()) {
                _state = PUNCHSTRONG_RIGHT;
                animation.play("punch-strong-right");
             } else {
				_state = PUNCHSTRONG_LEFT;
				animation.play("punch-strong-left");
             }
        }

        if (key == "D") {
            if (isRight()) {
                _state = GUARD_RIGHT;
                animation.play("guard-right");
            } else {
                _state = GUARD_LEFT;
                animation.play("guard-left");
            }
        }

		safePositions();

		super.update(elapsed);
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

	private function isLeft():Bool {
		if (_state == LEFT || _state == IDLE_LEFT || _state == PUNCH_LEFT ||
		_state == PUNCHSTRONG_LEFT || _state == GUARD_LEFT) {
			return true;
		}

		return false;
	}

	private function isRight():Bool {
		if (_state == RIGHT || _state == IDLE_RIGHT || _state == PUNCH_RIGHT ||
		_state == PUNCHSTRONG_RIGHT || _state == GUARD_RIGHT) {
			return true;
		}

		return false;
	}

    private function isFighting():Bool {
		if (_state == PUNCH_LEFT || _state == PUNCH_RIGHT ||
		_state == PUNCHSTRONG_LEFT || _state == PUNCHSTRONG_RIGHT ||
		_state == GUARD_LEFT || _state == GUARD_RIGHT) {
			return true;
		}

		return false;
    }

	private function setIdle() {
		if(_state == PUNCH_LEFT || _state == PUNCHSTRONG_LEFT ||
		_state == GUARD_LEFT || _state == LEFT) {
			_state = IDLE_LEFT;
		} else {
			_state = IDLE_RIGHT;
		}
	}
}
