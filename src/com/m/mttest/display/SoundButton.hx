package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class SoundButton  extends Entity
{
	
	static public var ON:String = "on";
	static public var OFF:String = "off";
	
	public function new () {
		super();
		
		var _anim:Animation;
		_anim = new Animation(ON, "tiles");
		_anim.addFrame(new AnimFrame("icon_sound_on"));
		anims.push(_anim);
		_anim = new Animation(OFF, "tiles");
		_anim.addFrame(new AnimFrame("icon_sound_off"));
		anims.push(_anim);
		
		play(ON);
	}
	
	override public function clickHandler () :Void {
		if (currentAnimName == ON)	play(OFF);
		else						play(ON);
		super.clickHandler();
	}
	
}