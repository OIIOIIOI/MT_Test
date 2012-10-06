package com.m.mttest.fx;

import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class AdvancedFadeFX extends FX
{
	
	private var values:Array<ColorTransform>;
	public var transform (getTransform, null):ColorTransform;
	
	public function new (_duration:Int, _values:Array<ColorTransform>, ?_callback:Dynamic, ?_fps:Int = 40)
	{
		super(_duration, _callback, _fps);
		
		values = _values;
	}
	
	private function getTransform () :ColorTransform
	{
		var _transform:ColorTransform = new ColorTransform();
		_transform.redMultiplier = values[0].redMultiplier - (values[0].redMultiplier - values[1].redMultiplier) * elapsed / duration;
		_transform.greenMultiplier = values[0].greenMultiplier - (values[0].greenMultiplier - values[1].greenMultiplier) * elapsed / duration;
		_transform.blueMultiplier = values[0].blueMultiplier - (values[0].blueMultiplier - values[1].blueMultiplier) * elapsed / duration;
		_transform.alphaMultiplier = values[0].alphaMultiplier - (values[0].alphaMultiplier - values[1].alphaMultiplier) * elapsed / duration;
		_transform.redOffset = values[0].redOffset - (values[0].redOffset - values[1].redOffset) * elapsed / duration;
		_transform.greenOffset = values[0].greenOffset - (values[0].greenOffset - values[1].greenOffset) * elapsed / duration;
		_transform.blueOffset = values[0].blueOffset - (values[0].blueOffset - values[1].blueOffset) * elapsed / duration;
		_transform.alphaOffset = values[0].alphaOffset - (values[0].alphaOffset - values[1].alphaOffset) * elapsed / duration;
		return _transform;
	}
	
}










