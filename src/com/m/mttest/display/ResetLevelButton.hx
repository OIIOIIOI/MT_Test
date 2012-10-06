package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class ResetLevelButton extends Button
{
	
	static public var RESET:String = "reset";
	
	public function new (_GUI:Interface) {
		super(_GUI);
		color = 0xFF000000;
		
		var _anim:Animation;
		_anim = new Animation(RESET, "tiles");
		_anim.addFrame(new AnimFrame("reset_level"));
		anims.push(_anim);
		
		play(RESET);
	}
	
}
