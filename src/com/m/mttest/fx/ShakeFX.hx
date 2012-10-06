package com.m.mttest.fx;

import flash.geom.Point;

/**
 * ...
 * @author 01101101
 */

class ShakeFX extends FX
{
	
	static public var VERTICAL:String = "vertical";
	static public var HORIZONTAL:String = "horizontal";
	static public var BOTH:String = "both";
	
	public var offset (default, null):Point;
	private var type:String;
	private var amount:Int;
	
	public function new (_duration:Int, ?_type:String, ?_amount:Int = 10, ?_callback:Dynamic, ?_fps:Int = 25)
	{
		super(_duration, _callback, _fps);
		
		if (_type == null)	_type = BOTH;
		type = _type;
		amount = _amount;
		offset = new Point();
	}
	
	override private function draw () :Void
	{
		if (type == HORIZONTAL || type == BOTH) {
			if (offset.x >= 0)	offset.x = -Std.random(amount + 1);
			else				offset.x = Std.random(amount + 1);
		}
		if (type == VERTICAL || type == BOTH) {
			if (offset.y >= 0)	offset.y = -Std.random(amount + 1);
			else				offset.y = Std.random(amount + 1);
		}
		
		super.draw();
	}
	
}










