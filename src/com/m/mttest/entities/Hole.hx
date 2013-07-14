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

class Hole extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, _variant:Int) {
		super(_x, _y, _level, LEType.hole);
		
		variant = _variant;
		hitBox = new Rectangle(7, 7, 2, 2);
		//drawHitBox = true;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("hole"));
		anims.push(_anim);
		play(IDLE);
	}
	
	override private function get_walkable () :Bool {
		return (variant == 0);
	}
	
}
