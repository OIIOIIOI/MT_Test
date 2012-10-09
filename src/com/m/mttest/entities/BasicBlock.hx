package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.levels.Level;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

class BasicBlock extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, _type:LEType) {
		super(_x, _y, _level, _type);
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		if (_type == unbreakable_wall) {
			_anim.addFrame(new AnimFrame("fence" + Std.random(3)));
		}
		else if (_type == blocked) {
			_anim.addFrame(new AnimFrame("seed" + Std.random(2)));
		}
		else if (_type == floor) {
			_anim.addFrame(new AnimFrame("grass" + Std.random(8)));
		}
		else if (_type == exit) {
			_anim.addFrame(new AnimFrame("exit"));
			// Shine FX
			var _shine:ShineFX = new ShineFX();
			_shine.mouseEnabled = false;
			addChild(_shine);
		}
		if (_anim.frames.length > 0) {
			anims.push(_anim);
			play(IDLE);
		}
	}
	
}