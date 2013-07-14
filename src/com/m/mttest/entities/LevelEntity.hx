package com.m.mttest.entities;

import com.m.mttest.Game;
import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.BasicBlock;
import com.m.mttest.entities.Bomb;
import com.m.mttest.entities.Sheep;
import com.m.mttest.entities.Wall;
import com.m.mttest.entities.Rock;
import com.m.mttest.levels.Level;

/**
 * ...
 * @author 01101101
 */

class LevelEntity extends Entity
{
	
	public var type (default, null):LEType;
	public var mapX (default, null):Int;
	public var mapY (default, null):Int;
	private var level:Level;
	
	public var active:Bool;
	public var walkable (get_walkable, never):Bool;
	public var destructible (get_destructible, never):Bool;
	public var variant (get_variant, null):Int;
	public var userPlaced:Bool;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, ?_type:LEType = null) {
		super();
		// Common init
		mapX = _x;
		mapY = _y;
		x = _x * Game.TILE_SIZE;
		y = _y * Game.TILE_SIZE;
		level = _level;
		type = (_type != null)? _type : LEType.unbreakable_wall;
		variant = 0;
		width = height = Game.TILE_SIZE;
		color = 0xFF000000 + typeToColor(_type);
		userPlaced = false;
		active = false;
	}
	
	private function get_variant () :Int {
		return variant;
	}
	
	override public function clickHandler () :Void {
		level.entityClickHandler(this);
		//trace("clicked " + this + " (" + type + ")");
	}
	
	public function activate () :Void {
		active = true;
	}
	
	public function blowUp (_power:Int = 1) :Void {
		level.updateMap();
	}
	
	private function get_walkable () :Bool {
		return switch (type) {
			case unbreakable_wall, border, blocked: false;
			case floor, sheep, exit, blast, hole: true;
			case bomb: (level.absoluteSearch || cast(this, Bomb).state == BombState.gone);
			case wall: (level.absoluteSearch || cast(this, Wall).state == WallState.gone);
			case rock: (level.absoluteSearch || cast(this, Rock).state == RockState.gone);
		}
	}
	
	public function stopsBlast () :Bool {
		return switch (type) {
			case unbreakable_wall: true;
			case floor, exit, blast, sheep, hole, blocked, border: false;
			case bomb: (cast(this, Bomb).state != BombState.gone);
			case wall: (cast(this, Wall).state != WallState.gone);
			case rock: (cast(this, Rock).state != RockState.gone);
		}
	}
	
	private function get_destructible () :Bool {
		return switch (type) {
			case unbreakable_wall, hole, floor, exit, blast, blocked, border: false;
			case bomb, sheep: true;
			case wall: (cast(this, Wall).state != WallState.gone);
			case rock: (cast(this, Rock).state != RockState.gone);
		}
	}
	
	static public function typeToClass (_type:LEType) :String {
		return switch (_type) {
			case unbreakable_wall:	"com.m.mttest.entities.BasicBlock";
			case floor:				"com.m.mttest.entities.BasicBlock";
			case blocked:			"com.m.mttest.entities.BasicBlock";
			case exit:				"com.m.mttest.entities.BasicBlock";
			case border:			"com.m.mttest.entities.Border";
			case hole:				"com.m.mttest.entities.Hole";
			case bomb:				"com.m.mttest.entities.Bomb";
			case sheep:				"com.m.mttest.entities.Sheep";
			case wall:				"com.m.mttest.entities.Wall";
			case rock:				"com.m.mttest.entities.Rock";
			case blast:				"com.m.mttest.entities.Blast";
		}
	}
	
	static public function typeToName (_type:LEType, _variant:Int = 0) :String {
		return switch (_type) {
			case unbreakable_wall:	"Fence";
			case floor:				"Field Grass";
			case blocked:			"Crop";
			case exit:				"Green Grass";
			case border:			"...";
			case hole:				"Hole";
			case bomb:				Bomb.getName(_variant);
			case sheep:				"Sheep";
			case wall:				"Straw";
			case rock:				"Rock";
			case blast:				"...";
		}
	}
	
	static public function typeToDesc (_type:LEType, _variant:Int = 0) :Array<String> {
		return switch (_type) {
			case unbreakable_wall:	["Fences stop everything!", "They're even harder than rock, somehow."];
			case floor:				["Place things here.", "If you want to, that is... A bomb, maybe?"];
			case blocked:			["The farmer got there first.", "You can't place bombs here."];
			case exit:				["The sheep need to go here,", "where the grass is greener..."];
			case border:			null;
			case hole:				["Hey, a sheep-sized hole!", "What a coincidence, right?!"];
			case bomb:				Bomb.getDesc(_variant);
			case sheep:				["Baaaaaaaaah!"];
			case wall:				["Blowing up haystack:", "looking for needles like a boss."];
			case rock:				["One blast will not be enough", "to destroy this rock."];
			case blast:				null;
		}
	}
	
	static public function getConstructorParams (_type:LEType, _variant:Int = 0) :Array<Dynamic> {
		return switch (_type) {
			case bomb, hole, border:						[_variant];
			case sheep, wall, rock, blast:					[];
			case unbreakable_wall, floor, exit, blocked:	[_type];
		}
	}
	
	static public function typeToColor (_type:LEType) :UInt {
		return switch (_type) {
			case unbreakable_wall:	0xFF00FF;
			case hole:				0xCC00CC;
			case blocked:			0x990099;
			case border:			0x660066;
			case floor:				0x9999FF;
			case wall:				0x6666FF;
			case rock:				0x3333FF;
			case bomb:				0xFF0000;
			case sheep:				0xFFCC00;
			case exit:				0x00FF00;
			case blast:				0xFFFF00;
			
		}
	}
	
	static public function colorToType (_color:UInt) :LEType {
		return switch (_color) {
			case 0x9999FF:	floor;
			case 0x6666FF:	wall;
			case 0x3333FF:	rock;
			case 0xFF0000:	bomb;
			case 0xFFCC00:	sheep;
			case 0x00FF00:	exit;
			case 0xFFFF00:	blast;
			case 0xFF00FF:	unbreakable_wall;
			case 0xCC00CC:	hole;
			case 0x990099:	blocked;
			case 0x660066:	border;
			default:		null;
		}
	}
	
}

enum LEType {
	unbreakable_wall;
	border;
	hole;
	blocked;
	floor;
	sheep;
	exit;
	wall;
	rock;
	bomb;
	blast;
}
