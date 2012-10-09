package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.display.BitmapText;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.Game;
import com.m.mttest.levels.Inventory;

/**
 * ...
 * @author 01101101
 */

class InvEntity extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public var type (default, null):LEType;
	public var variant:Int;
	private var inventory:Inventory;
	
	public function new (_type:LEType, _variant:Int = 0, _inventory:Inventory) {
		super();
		
		type = _type;
		variant = _variant;
		inventory = _inventory;
		
		x = y = 4;
		width = height = Game.TILE_SIZE;
		color = 0xFF000000 + LevelEntity.typeToColor(_type);
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame(typeToFrame(type, _variant)));
		anims.push(_anim);
		play(IDLE);
		
		var _extra:Entity = getExtra(_type, _variant);
		if (_extra != null)	addChild(_extra);
	}
	
	override public function clickHandler () :Void {
		inventory.entityClickHandler(cast(this.parent, InvSlot));
		//trace("clicked " + this + " (" + type + ")");
	}
	
	static public function getExtra (_type:LEType, _variant:Int = 0) :Entity {
		var _extra:Entity = null;
		if (_type == LEType.bomb) {
			var _timer:Int = _variant % 256;
			if (_timer > 0) {
				_extra = new BitmapText(Std.string(_timer), "font_numbers_red");
				_extra.mouseEnabled = false;
				_extra.x = Game.TILE_SIZE - _extra.width - 1;
				_extra.y = Game.TILE_SIZE - _extra.height - 1;
			}
		}
		return _extra;
	}
	
	static public function typeToFrame (_type:LEType, _variant:Int = 0) :String {
		return switch (_type) {
			case unbreakable_wall:	"fence0";
			case hole:				"hole";
			case floor:				"grass4";
			case blocked:			"seed0";
			case exit:				"exit0";
			case bomb:				"bomb" + Math.floor(_variant / 256);
			case sheep:				"sheep0";
			case wall:				"wall0";
			case rock:				"rock0";
			case blast:				"blast3";
			case border:			"border_bottom";
		}
	}
	
}