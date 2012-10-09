package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class ShineFX extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public function new () {
		super();
		//
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("shineFX0"));
		_anim.addFrame(new AnimFrame("shineFX1"));
		_anim.addFrame(new AnimFrame("shineFX2"));
		_anim.addFrame(new AnimFrame("shineFX3"));
		_anim.addFrame(new AnimFrame("shineFX4"));
		_anim.addFrame(new AnimFrame("shineFX5"));
		_anim.fps = 10;
		anims.push(_anim);
		play(IDLE);
	}
	
}