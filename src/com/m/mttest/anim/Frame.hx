package com.m.mttest.anim;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

class Frame
{
	
	public var spritesheet:BitmapData;
	public var name:String;
	public var uid:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	
	public function new (?_name:String = "", ?_uid:String = "", ?_x:Int = 0, ?_y:Int = 0, ?_width:Int = 1, ?_height:Int = 1) {
		name = _name;
		uid = _uid;
		x = _x;
		y = _y;
		width = _width;
		height = _height;
	}
	
	public function fromObject (_data:Dynamic) :Void {
		name = _data.name;
		uid = _data.uid;
		x = _data.x;
		y = _data.y;
		width = _data.width;
		height = _data.height;
	}
	
}