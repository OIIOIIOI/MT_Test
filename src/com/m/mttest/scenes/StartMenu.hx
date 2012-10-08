package com.m.mttest.scenes;

import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class StartMenu extends Scene
{
	
	public function new () {
		super();
		
		var _test:Entity = new Entity();
		_test.x = _test.y = 16;
		_test.width = _test.height = 64;
		_test.color = 0xFF000000 + Std.random(0xFFFFFF);
		addChild(_test);
	}
	
}