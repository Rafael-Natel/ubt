package;

import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import haxe.Json;
import Player;
import Message;

typedef RemoteData = {
	var x:Int;
	var y:Int;
}

class RemotePlayer extends FlxSprite
{
	public static inline var RUN_SPEED:Int = 90;
	public static inline var GRAVITY:Int = 440;

    private var _parent:PlayState;
	private var _state:State;
	private var _connection:sys.net.Socket;
	private var _lastUpdate:Float = 0;
	private var _lastTime:Date;

	public function new(X:Int, Y:Int, state:State, connection:sys.net.Socket)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		_connection = connection;
		_state = state;

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

	private function updatePlayer() {
		try {
			var recvMessage:String = _connection.input.readLine();
			var dataObj:PlayerInfo = Json.parse(recvMessage);

			trace("remote received: ", recvMessage);

			this.x = dataObj.x;
			this.y = dataObj.y;

		} catch(msg:String) {
			trace("ERROR:", msg);
		}
	}

	public override function update(elapsed:Float):Void
	{
		var currentTime:Date = Date.now();

		if (currentTime.getTime() > _lastTime.getTime() + 500) {
			_lastTime = currentTime;
			updatePlayer();
		}

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
