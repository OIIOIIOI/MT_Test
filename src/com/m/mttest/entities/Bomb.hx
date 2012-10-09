package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.display.BitmapText;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.fx.ColorBlinkFX;
import com.m.mttest.levels.Level;
import flash.display.BlendMode;
import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class Bomb extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	static public var ON:String = "on";
	static public var BOOM:String = "boom";
	
	static private var DELAY:Int = 1200;
	
	public var state (default, null):BombState;
	
	private var size:Int;
	private var number:BitmapText;
	private var timer:Int;
	private var left:Int;
	private var startTime:Float;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, _variant:Int) {
		super(_x, _y, _level, LEType.bomb);
		
		state = normal;
		// Extract params from variant color
		variant = _variant;
		size = Math.floor(_variant / 256);
		timer = _variant % 256;
		//
		left = timer;
		// Add timer entity
		if (timer > 0) {
			number = new BitmapText(Std.string(timer), "font_numbers_red");
			number.mouseEnabled = false;
			number.x = width - number.width - 1;
			number.y = height - number.height - 1;
			addChild(number);
		}
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("bomb" + size));
		anims.push(_anim);
		_anim = new Animation(ON, "tiles");
		_anim.addFrame(new AnimFrame("bomb" + size + "_on0"));
		_anim.addFrame(new AnimFrame("bomb" + size + "_on1"));
		anims.push(_anim);
		_anim = new Animation(BOOM, "tiles");
		_anim.addFrame(new AnimFrame("bomb" + size + "_burn"));
		anims.push(_anim);
		
		play(IDLE);
	}
	
	/*override private function getVariant () :Int {
		return (size * 256 + timer);
	}*/
	
	override public function activate () :Void {
		startTime = Date.now().getTime();
		play(ON);
		super.activate();
	}
	
	override public function update () :Void {
		if (active) {
			var _diff:Float = Date.now().getTime() - startTime;
			if (timer - Math.floor(_diff / DELAY) < left) {
				left = timer - Math.floor(_diff / DELAY);
				//
				if (left == 1)
					addFX(new ColorBlinkFX(-1, new ColorTransform(1, 1, 1, 1, 255, 255, 255), null, 18), false);
				if (left > 0 && number != null) {
					number.text = Std.string(left);
					number.x = width - number.width - 1;
					number.y = height - number.height - 1;
				}
			}
			if (state == normal && _diff > DELAY * timer) {
				blowUp();
			}
		}
		super.update();
	}
	
	override public function blowUp (_power:Int = 1) :Void {
		if (number != null) {
			removeChild(number);
			number = null;
		}
		state = gone;
		active = false;
		
		removeFX();
		blendMode = BlendMode.MULTIPLY;
		play(BOOM);
		
		level.blastBomb(mapX, mapY, size + 1);
		super.blowUp(_power);
		
		EventManager.instance.dispatchEvent(new GameEvent(GameEvent.BOMB_EXPLODED));
	}
	
	static public function getName (_variant:Int = 0) :String {
		var _name:String = "Bomb";
		if (Math.floor(_variant / 256) > 0)	_name = "Big Bomb";
		if (_variant % 256 > 0)	_name = "Timed " + _name;
		return _name;
	}
	
	static public function getDesc (_variant:Int = 0) :Array<String> {
		var _size:Int = Math.floor(_variant / 256);
		var _timer:Int = _variant % 256;
		if (_size == 0 && _timer == 0)		return ["Small bomb"];
		else if (_size == 0 && _timer > 0)	return ["Small bomb with timer"];
		else if (_size > 0 && _timer == 0)	return ["Big bomb"];
		else								return ["Big bomb with timer"];
	}
	
}

enum BombState {
	normal;
	gone;
}










