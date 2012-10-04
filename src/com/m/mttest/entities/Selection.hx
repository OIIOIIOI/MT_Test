package com.m.mttest.entities;
import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class Selection extends Entity
{
	
	static public var STATIC:String = "static";
	static public var ANIMATED:String = "animated";
	
	public function new () {
		super();
		
		alpha = 0.7;
		
		var _anim:Animation;
		_anim = new Animation(STATIC, "tiles");
		_anim.addFrame(new AnimFrame("selection_static"));
		anims.push(_anim);
		_anim = new Animation(ANIMATED, "tiles");
		_anim.addFrame(new AnimFrame("selection_anim_0"));
		_anim.addFrame(new AnimFrame("selection_anim_1"));
		_anim.addFrame(new AnimFrame("selection_anim_2"));
		_anim.addFrame(new AnimFrame("selection_anim_3"));
		anims.push(_anim);
		
		play(ANIMATED);
	}
	
}