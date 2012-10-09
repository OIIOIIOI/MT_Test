package com.m.mttest.entities;
import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;

/**
 * ...
 * @author 01101101
 */

class DisplaySheep extends Entity
{
	
	static public var IDLE:String = "idle";
	static public var JUMP:String = "jump";
	static public var MOVING:String = "moving";
	static public var FALL:String = "fall";
	static public var DEAD:String = "dead";
	
	private var sleepFX:SleepFX;
	
	public function new () {
		super();
		
		sleepFX = new SleepFX();
		sleepFX.x = 1;
		sleepFX.y = -8;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("sheep_asleep"));
		anims.push(_anim);
		_anim = new Animation(MOVING, "tiles");
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.addFrame(new AnimFrame("sheep1"));
		_anim.fps = 8;
		anims.push(_anim);
		_anim = new Animation(JUMP, "tiles");
		_anim.addFrame(new AnimFrame("sheep_jump"));
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.fps = 10;
		anims.push(_anim);
		_anim = new Animation(FALL, "tiles");
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall1"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall1"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall2"));
		_anim.addFrame(new AnimFrame("sheep_fall3"));
		_anim.looping = false;
		_anim.fps = 10;
		anims.push(_anim);
		_anim = new Animation(DEAD, "tiles");
		_anim.addFrame(new AnimFrame("sheep_cry0"));
		_anim.addFrame(new AnimFrame("sheep_cry1"));
		_anim.addFrame(new AnimFrame("sheep_cry2"));
		_anim.addFrame(new AnimFrame("sheep_cry3"));
		_anim.addFrame(new AnimFrame("sheep_cry4"));
		_anim.fps = 18;
		anims.push(_anim);
		
		play(JUMP);
	}
	
	override public function play (_animName:String) :Void {
		if (_animName == IDLE)	addChild(sleepFX);
		else					removeChild(sleepFX);
		super.play(_animName);
	}
	
}