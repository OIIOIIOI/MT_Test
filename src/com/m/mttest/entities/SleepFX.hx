package com.m.mttest.entities;
import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class SleepFX extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public function new () {
		super();
		
		mouseEnabled = false;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("sleep_fx0"));
		_anim.addFrame(new AnimFrame("sleep_fx1"));
		_anim.addFrame(new AnimFrame("sleep_fx2"));
		_anim.addFrame(new AnimFrame("sleep_fx3"));
		_anim.fps = 6;
		anims.push(_anim);
		
		play(IDLE);
		currentFrame = Std.random(4);
	}
	
}