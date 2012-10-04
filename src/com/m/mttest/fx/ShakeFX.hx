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
	private var m_type:String;
	private var m_amount:Int;
	
	public function new (_duration:Int, ?_type:String, ?_amount:Int = 10, ?_callback:Dynamic, ?_fps:Int = 25)
	{
		super(_duration, _callback, _fps);
		
		if (_type == null)	_type = BOTH;
		m_type = _type;
		m_amount = _amount;
		offset = new Point();
	}
	
	override private function draw () :Void
	{
		if (m_type == HORIZONTAL || m_type == BOTH) {
			if (offset.x >= 0)	offset.x = -Std.random(m_amount + 1);
			else				offset.x = Std.random(m_amount + 1);
		}
		if (m_type == VERTICAL || m_type == BOTH) {
			if (offset.y >= 0)	offset.y = -Std.random(m_amount + 1);
			else				offset.y = Std.random(m_amount + 1);
		}
		
		super.draw();
	}
	
}










