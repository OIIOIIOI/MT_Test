package com.m.mttest.display;

import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class Button extends Entity
{
	
	private var GUI:Interface;
	
	public function new (_GUI:Interface) {
		super();
		GUI = _GUI;
		width = height = 16;
		color = 0xFF000000 + Std.random(0xFFFFFF);
	}
	
	override public function clickHandler () :Void {
		GUI.entityClickHandler(this);
	}
	
}