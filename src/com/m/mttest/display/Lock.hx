package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class Lock extends Entity
{
	
	static public var CLOSED:String = "closed";
	static public var OPEN:String = "open";
	
	public function new (_type:String = "gold") {
		super();
		
		var _anim:Animation;
		_anim = new Animation(CLOSED, "tiles");
		_anim.addFrame(new AnimFrame("lock_" + _type + "_closed"));
		anims.push(_anim);
		_anim = new Animation(OPEN, "tiles");
		_anim.addFrame(new AnimFrame("lock_" + _type + "_open"));
		anims.push(_anim);
		
		play(CLOSED);
	}
	
}