package com.m.mttest.display;

import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class Interface extends Entity
{
	
	public function new () {
		super();
		
		var _button:Button = new Button();
		addChild(_button);
	}
	
}