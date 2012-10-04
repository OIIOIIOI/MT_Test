package com.m.mttest.fx;

/**
 * ...
 * @author 01101101
 */

class FX
{
	
	public var complete (default, null):Bool;
	private var m_duration:Int;
	private var m_elapsed:Int;
	private var m_callback:Dynamic;
	private var m_fps:Int;
	private var m_lastDraw:Float;
	
	public function new (_duration:Int, ?_callback:Dynamic, ?_fps:Int = 25)
	{
		m_duration = _duration;
		m_callback = _callback;
		m_fps = _fps;
		m_elapsed = 0;
		complete = false;
		m_lastDraw = Date.now().getTime();
	}
	
	public function update () :Void
	{
		if (Date.now().getTime() - m_lastDraw > 1000 / m_fps) {
			// Draw
			draw();
			// Update if duration > -1 (not infinite)
			if (m_duration > -1) {
				m_elapsed++;
				if (m_elapsed >= m_duration) {
					m_elapsed = m_duration;
					if (!complete) {
						complete = true;
						if (m_callback != null)	m_callback();
					}
				}
			}
			m_lastDraw = Date.now().getTime();
		}
	}
	
	private function draw () :Void { }
	
}