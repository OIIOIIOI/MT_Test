package com.m.mttest.fx;

import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class ColorFX extends FX
{
	
	public var transform (default, null):ColorTransform;
	
	public function new (?_duration:Int = -1, ?_transform:ColorTransform, ?_callback:Dynamic)
	{
		super(_duration, _callback);
		
		if (_transform == null)
			_transform = new ColorTransform(1, 1, 1, 0);
		transform = _transform;
	}
	
}