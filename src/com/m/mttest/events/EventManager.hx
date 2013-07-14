package com.m.mttest.events;

import flash.errors.Error;
import flash.events.EventDispatcher;

/**
 * ...
 * @author 01101101
 */

class EventManager extends EventDispatcher
{
	
	static public var instance (get_instance, null):EventManager;
	static private var safe:Bool;
	
	public function new () {
		super();
		if (safe)	instance = this;
		else		throw new Error("EventManager already instanciated. Use EventManager.instance instead.");
	}
	
	static private function get_instance () :EventManager {
		if (instance == null) {
			safe = true;
			new EventManager();
			safe = false;
		}
		return instance;
	}
	
}
