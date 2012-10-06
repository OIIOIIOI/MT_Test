package com.m.mttest.fx;

/**
 * ...
 * @author 01101101
 */

class FX
{
	
	public var complete (default, null):Bool;
	private var duration:Int;
	private var elapsed:Int;
	private var callbackFunction:Dynamic;
	private var fps:Int;
	private var lastDraw:Float;
	
	public function new (_duration:Int, ?_callback:Dynamic, ?_fps:Int = 25)
	{
		duration = _duration;
		callbackFunction = _callback;
		fps = _fps;
		elapsed = 0;
		complete = false;
		lastDraw = Date.now().getTime();
	}
	
	public function update () :Void
	{
		if (Date.now().getTime() - lastDraw > 1000 / fps) {
			// Draw
			draw();
			// Update if duration > -1 (not infinite)
			if (duration > -1) {
				elapsed++;
				if (elapsed >= duration) {
					elapsed = duration;
					if (!complete) {
						complete = true;
						if (callbackFunction != null)	callbackFunction();
					}
				}
			}
			lastDraw = Date.now().getTime();
		}
	}
	
	private function draw () :Void { }
	
}