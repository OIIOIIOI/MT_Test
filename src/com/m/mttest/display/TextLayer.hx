package com.m.mttest.display;

import com.m.mttest.entities.Entity;
import flash.errors.Error;

/**
 * ...
 * @author 01101101
 */

class TextLayer extends Entity
{
	
	static public var instance (getInstance, null):TextLayer;
	static private var safe:Bool;
	
	public function new () {
		super();
		if (safe)	instance = this;
		else		throw new Error("TextLayer already instanciated. Use TextLayer.instance instead.");
	}
	
	static private function getInstance () :TextLayer {
		if (instance == null) {
			safe = true;
			new TextLayer();
			safe = false;
		}
		return instance;
	}
	
}