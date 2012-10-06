package com.m.mttest.fx;

/**
 * ...
 * @author 01101101
 */

class FadeFX extends FX
{
	
	static public var FADE_IN:Array<Float> = [0, 1];
	static public var FADE_OUT:Array<Float> = [1, 0];
	
	public var alpha (getAlpha, null):Float;
	private var values:Array<Float>;
	
	public function new (_duration:Int, _values:Array<Float>, ?_callback:Dynamic, ?_fps:Int = 40)
	{
		super(_duration, _callback, _fps);
		
		values = _values;
		
		alpha = values[0];
	}
	
	private function getAlpha () :Float
	{
		var _value:Float = values[0] - (values[0] - values[1]) * elapsed / duration;
		return _value;
	}
	
}










