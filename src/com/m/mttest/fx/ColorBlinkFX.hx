package com.m.mttest.fx;

import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class ColorBlinkFX extends FX
{
	
	public var on (default, null):Bool;
	public var transform (default, null):ColorTransform;
	
	public function new (_duration:Int, ?_transform:ColorTransform, ?_callback:Dynamic, ?_fps:Int = 25)
	{
		super(_duration, _callback, _fps);
		
		if (_transform == null)
			_transform = new ColorTransform(1, 1, 1, 0);
		transform = _transform;
		on = false;
	}
	
	override private function draw () :Void
	{
		on = !on;
		super.draw();
	}
	
}