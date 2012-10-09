package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class PlayLevelButton extends Entity
{
	
	static public var PLAY:String = "play";
	static public var STOP:String = "stop";
	
	public function new () {
		super();
		
		var _anim:Animation;
		_anim = new Animation(PLAY, "tiles");
		_anim.addFrame(new AnimFrame("icon_play"));
		anims.push(_anim);
		_anim = new Animation(STOP, "tiles");
		_anim.addFrame(new AnimFrame("icon_stop"));
		anims.push(_anim);
		
		play(PLAY);
	}
	
	override public function clickHandler () :Void {
		if (currentAnimName == PLAY)	play(STOP);
		else							play(PLAY);
		super.clickHandler();
	}
	
}
