package com.m.mttest.anim;

/**
 * ...
 * @author 01101101
 */

class AnimFrame
{
	
	public var name:String; // A Frame name
	//public var duration:Int;
	public var x:Int;
	public var y:Int;
	public var flipped:Bool;
	
	public function new (_name:String, ?_x:Int = 0, ?_y:Int = 0, ?_flipped:Bool = false) {
		name = _name;
		x = _x;
		y = _y;
		flipped = _flipped;
	}
	
}