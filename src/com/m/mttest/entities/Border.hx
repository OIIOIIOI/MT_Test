package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.levels.Level;

/**
 * ...
 * @author 01101101
 */

class Border extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, _variant:Int) {
		super(_x, _y, _level, LEType.border);
		
		variant = _variant;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		switch (variant) {
			default:	_anim.addFrame(new AnimFrame("border_top"));
			case 1:		_anim.addFrame(new AnimFrame("border_upper_corner", 0, 0, true));
			case 2:		_anim.addFrame(new AnimFrame("border_side", 0, 0, true));
			case 3:		_anim.addFrame(new AnimFrame("border_lower_corner", 0, 0, true));
			case 4:		_anim.addFrame(new AnimFrame("border_bottom"));
			case 5:		_anim.addFrame(new AnimFrame("border_lower_corner"));
			case 6:		_anim.addFrame(new AnimFrame("border_side"));
			case 7:		_anim.addFrame(new AnimFrame("border_upper_corner"));
		}
		anims.push(_anim);
		play(IDLE);
	}
	
}
