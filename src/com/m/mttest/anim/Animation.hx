package com.m.mttest.anim;

/**
 * ...
 * @author 01101101
 */

class Animation
{
	
	public var name:String;
	public var spritesheet:String;
	public var frames (default, null):Array<AnimFrame>;
	public var fps:Int;
	public var looping:Bool;
	
	public function new (_name:String, ?_spritesheet:String) {
		name = _name;
		spritesheet = _spritesheet;
		frames = new Array<AnimFrame>();
		fps = 12;
		looping = true;
	}
	
	public function addFrame (_animFrame:AnimFrame) :Void {
		frames.push(_animFrame);
	}
	
}