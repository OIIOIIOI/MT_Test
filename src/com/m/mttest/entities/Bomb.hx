package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.fx.AdvancedFadeFX;
import com.m.mttest.fx.ColorBlinkFX;
import com.m.mttest.fx.ColorFX;
import com.m.mttest.Game;
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
	
	static private var DELAY:Int = 1000;
	
	public var state (default, null):BombState;
	
	private var size:Int;
	private var number:NumberDisplay;
	private var timer:Int;
	private var left:Int;
	private var startTime:Float;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, _size:Int) {
		super(_x, _y, _level, LEType.bomb);
		
		state = normal;
		size = _size;
		//timer = Std.random(5);
		timer = 0;
		left = timer;
		
		if (timer > 0) {
			number = new NumberDisplay(timer);
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
					number.play("number" + left);
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
		
		level.blastBomb(mapX, mapY);
		
		super.blowUp(_power);
	}
	
}

enum BombState {
	normal;
	gone;
}










