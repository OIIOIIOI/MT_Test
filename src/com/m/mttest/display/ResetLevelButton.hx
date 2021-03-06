package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class ResetLevelButton extends Entity
{
	
	static public var ON:String = "on";
	static public var OFF:String = "off";
	
	public function new () {
		super();
		
		var _anim:Animation;
		_anim = new Animation(ON, "tiles");
		_anim.addFrame(new AnimFrame("icon_reset_on"));
		anims.push(_anim);
		_anim = new Animation(OFF, "tiles");
		_anim.addFrame(new AnimFrame("icon_reset_off"));
		anims.push(_anim);
		
		play(OFF);
	}
	
}
