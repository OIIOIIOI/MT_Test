package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.fx.ColorBlinkFX;

/**
 * ...
 * @author 01101101
 */

class WakeFX extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public function new () {
		super();
		
		mouseEnabled = false;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("wake_fx"));
		anims.push(_anim);
		
		play(IDLE);
		
		addFX(new ColorBlinkFX(-1, null, null, 10));
	}
	
}