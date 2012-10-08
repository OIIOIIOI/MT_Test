package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class FastEntity extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public function new (_frame:String, _spritesheet:String = "tiles") {
		super();
		
		var _anim:Animation;
		_anim = new Animation(IDLE, _spritesheet);
		_anim.addFrame(new AnimFrame(_frame));
		anims.push(_anim);
		play(IDLE);
	}
	
}