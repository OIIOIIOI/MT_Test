package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class NumberDisplay extends Entity
{
	
	public function new (_number:Int = 0) {
		super();
		
		mouseEnabled = false;
		
		_number = Std.int(Math.max(Math.min(_number, 9), 0));
		
		var _anim:Animation;
		for (_i in 0...10) {
			_anim = new Animation("number" + _i, "tiles");
			_anim.addFrame(new AnimFrame("number" + _i));
			anims.push(_anim);
		}
		
		play("number" + _number);
	}
	
}
