package com.m.mttest.events;

import flash.events.Event;

/**
 * ...
 * @author 01101101
 */

class GameEvent extends Event
{
	
	inline static public var CHANGE_SCENE:String = "change_scene";
	inline static public var LEVEL_PAUSED:String = "level_paused";
	inline static public var PLAY_LEVEL:String = "play_level";
	inline static public var RESET_LEVEL:String = "reset_level";
	inline static public var PLACE_ITEM:String = "place_item";
	inline static public var REMOVE_ITEM:String = "remove_item";
	inline static public var SHEEP_DIED:String = "sheep_died";
	inline static public var SHEEP_ARRIVED:String = "sheep_arrived";
	inline static public var BOMB_EXPLODED:String = "bomb_exploded";
	inline static public var SET_HINT:String = "set_hint";
	inline static public var EXIT_TUTO:String = "exit_tuto";
	
	public var data:Dynamic;
	
	public function new (type:String, ?_data:Dynamic = null, ?bubbles:Bool = false, ?cancelable:Bool = false) {
		data = _data;
		super(type, bubbles, cancelable);
	}
	
	public override function clone () :GameEvent {
		return new GameEvent(type, data, bubbles, cancelable);
	}
	
	public override function toString () :String {
		return formatToString("GameEvent", "data", "type", "bubbles", "cancelable", "eventPhase");
	}
	
}