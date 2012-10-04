package com.m.mttest.entities;

import com.m.mttest.Game;
import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.BasicBlock;
import com.m.mttest.entities.Bomb;
import com.m.mttest.entities.Sheep;
import com.m.mttest.entities.Wall;
import com.m.mttest.levels.Level;

/**
 * ...
 * @author 01101101
 */

class LevelEntity extends Entity
{
	
	static public var ACTION_SELECT:String = "action_select";
	static public var ACTION_PLACE:String = "action_place";
	
	public var type (default, null):LEType;
	public var mapX (default, null):Int;
	public var mapY (default, null):Int;
	private var level:Level;
	
	public var active:Bool;
	public var walkable (getWalkable, never):Bool;
	public var destructible (getDestructible, never):Bool;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, ?_type:LEType = null) {
		super();
		// Common init
		mapX = _x;
		mapY = _y;
		x = _x * Game.TILE_SIZE;
		y = _y * Game.TILE_SIZE;
		level = _level;
		type = (_type != null)? _type : LEType.unbreakable_wall;
		width = height = Game.TILE_SIZE;
		color = typeToColor(_type);
		active = false;
	}
	
	public function activate () :Void {
		active = true;
	}
	
	public function blowUp () :Void {
		level.updateMap();
	}
	
	private function getWalkable () :Bool {
		return switch (type) {
			case unbreakable_wall: false;
			case floor, sheep, exit, blast: true;
			case bomb: (level.absoluteSearch || cast(this, Bomb).state == BombState.gone);
			case wall: (level.absoluteSearch || cast(this, Wall).state == WallState.gone);
		}
	}
	
	public function stopsBlast () :Bool {
		return switch (type) {
			case unbreakable_wall: true;
			case floor, exit, blast, sheep: false;
			case bomb: (cast(this, Bomb).state != BombState.gone);
			case wall: (cast(this, Wall).state != WallState.gone);
		}
	}
	
	private function getDestructible () :Bool {
		return switch (type) {
			case unbreakable_wall: false;
			case floor: false;
			case bomb: true;
			case sheep: true;
			case exit: false;
			case wall: (cast(this, Wall).state != WallState.gone);
			case blast: false;
		}
	}
	
	static public function typeToClass (_type:LEType) :String {
		return switch (_type) {
			case unbreakable_wall:	"com.m.mttest.entities.BasicBlock";
			case floor:				"com.m.mttest.entities.BasicBlock";
			case bomb:				"com.m.mttest.entities.Bomb";
			case sheep:				"com.m.mttest.entities.Sheep";
			case exit:				"com.m.mttest.entities.BasicBlock";
			case wall:				"com.m.mttest.entities.Wall";
			case blast:				"com.m.mttest.entities.Blast";
		}
	}
	
	static public function getConstructorParams (_type:LEType) :Array<Dynamic> {
		return switch (_type) {
			case bomb, sheep, wall, blast:			[];
			case unbreakable_wall, floor, exit:	[_type];
		}
	}
	
	static public function typeToColor (_type:LEType) :UInt {
		return switch (_type) {
			case unbreakable_wall:	0xFF00FF;
			case floor:				0x999999;
			case bomb:				0xFF0000;
			case sheep:				0xFFCC00;
			case exit:				0x00FF00;
			case wall:				0x333333;
			case blast:				0xFFFF00;
			
		}
	}
	
	static public function colorToType (_color:UInt) :LEType {
		return switch (_color) {
			case 0x999999:	floor;
			case 0xFF0000:	bomb;
			case 0xFFCC00:	sheep;
			case 0x00FF00:	exit;
			case 0x333333:	wall;
			case 0xFFFF00:	blast;
			case 0xFF00FF:	unbreakable_wall;
			default:		null;
		}
	}
	
}

enum LEType {
	unbreakable_wall;
	floor;
	sheep;
	exit;
	wall;
	bomb;
	blast;
}








