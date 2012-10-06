package com.m.mttest.display;
import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class PlayLevelButton extends Button
{
	
	static public var PLAY:String = "play";
	static public var STOP:String = "stop";
	static public var RESET:String = "reset";
	
	public function new (_GUI:Interface) {
		super(_GUI);
		color = 0xFF000000;
		
		var _anim:Animation;
		_anim = new Animation(PLAY, "tiles");
		_anim.addFrame(new AnimFrame("play_level"));
		anims.push(_anim);
		_anim = new Animation(STOP, "tiles");
		_anim.addFrame(new AnimFrame("stop_level"));
		anims.push(_anim);
		
		play(PLAY);
	}
	
	override public function clickHandler () :Void {
		if (currentAnimName == PLAY)	play(STOP);
		else							play(PLAY);
		super.clickHandler();
	}
	
}
