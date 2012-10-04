package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.levels.Level;

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
		if (_type == unbreakable_wall)	_anim.addFrame(new AnimFrame("fence"));
		else if (_type == floor) {
			_anim.addFrame(new AnimFrame("grass" + Std.random(7)));
		}
		else if (_type == exit) {
			_anim.addFrame(new AnimFrame("exit0"));
			_anim.addFrame(new AnimFrame("exit1"));
			_anim.addFrame(new AnimFrame("exit2"));
			_anim.addFrame(new AnimFrame("exit3"));
			_anim.fps = 8;
		}
		if (_anim.frames.length > 0) {
			anims.push(_anim);
			play(IDLE);
		}
	}
	
}