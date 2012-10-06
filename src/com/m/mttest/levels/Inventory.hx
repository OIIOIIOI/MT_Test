package com.m.mttest.levels;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.anim.FrameManager;
import com.m.mttest.entities.Entity;
import com.m.mttest.entities.InvEntity;
import com.m.mttest.entities.LevelEntity;
import flash.display.BitmapData;
import flash.errors.Error;

/**
 * ...
 * @author 01101101
 */

class Inventory extends Entity
{
	
	private var invData:BitmapData;
	private var list:Array<InvObject>;
	private var index:Int;
	
	private var slots:Entity;
	
	public function new () {
		super();
		
		slots = new Entity();
		addChild(slots);
	}
	
	public function load (_name:String) :Void {
		// Get level data
		invData = FrameManager.getFrame(_name, "levels");
		if (invData == null)
			throw new Error("The inventory \"" + _name + "\" was found");
		//
		parse();
	}
	
	public function reset () :Void {
		for (_i in list)	_i.used = 0;
		refresh();
	}
	
	private function parse () :Void {
		index = -1;
		list = new Array<InvObject>();
		//
		var _color:UInt;
		var _type:LEType;
		var _variant:Int;
		var _indexOf:Int;
		for (_x in 0...Std.int(invData.width)) {
			// Item
			_color = invData.getPixel(_x, 0);
			_variant = invData.getPixel(_x, 1);
			if (_variant == Std.int(_color))	_variant = 0;
			_type = LevelEntity.colorToType(_color);
			//
			if (_type != null) {
				_indexOf = isInList(_type, _variant);
				if (_indexOf == -1)	list.push( { type:_type, variant:_variant, count:1, used:0 } );
				else				list[_indexOf].count++;
			}
		}
		width = 20;
		color = 0xFFE6D373;
		refresh();
		//trace("inventory: " + list);
	}
	
	private function refresh () :Void {
		if (slots.numChildren == 0) {
			var _slot:InvSlot;
			for (_i in 0...list.length) {
				_slot = new InvSlot(this);
				_slot.x = 1;
				_slot.y = _i * (_slot.height + 1) + 1;
				slots.addChild(_slot);
				if (height == 1)	height = list.length * (_slot.height + 1) + 2;
			}
		}
		for (_i in 0...slots.numChildren) {
			cast(slots.getChildAt(_i), InvSlot).display(null);
			slots.getChildAt(_i).play(InvSlot.OFF);
		}
		var _index:Int = 0;
		for (_i in 0...list.length) {
			if (list[_i].count > list[_i].used) {
				cast(slots.getChildAt(_index), InvSlot).listIndex = _i;
				cast(slots.getChildAt(_index), InvSlot).display(list[_i].type, list[_i].variant);
				_index++;
			}
		}
		// If at least one slot is full, select the first one
		if (_index > 0) {
			slots.getChildAt(0).play(InvSlot.ON);
			index = 0;
		}
		else index = -1;
	}
	
	private function isInList (_type:LEType, _variant:Int) :Int {
		for (_i in 0...list.length) {
			if (list[_i].type == _type && list[_i].variant == _variant)
				return _i;
		}
		return -1;
	}
	
	public function getSelected () :InvObject {
		if (index != -1) {
			var _selectedSlot:InvSlot = cast(slots.getChildAt(index), InvSlot);
			return list[_selectedSlot.listIndex];
		}
		else return null;
	}
	
	public function useItem (_invObject:InvObject) :Bool {
		if (_invObject == null)	return false;
		var _indexOf:Int = isInList(_invObject.type, _invObject.variant);
		// If not in inventory
		if (_indexOf == -1)	return false;
		// If out of stock
		if (list[_indexOf].used >= list[_indexOf].count)	return false;
		// All right
		list[_indexOf].used++;
		refresh();
		return true;
	}
	
	public function putBackItem (_type:LEType, _variant:Int) :Bool {
		var _indexOf:Int = isInList(_type, _variant);
		//trace("putBackItem " + _type + " / " + _variant + ": " + _indexOf);
		// If not in inventory
		if (_indexOf == -1)	return false;
		// If none was used
		if (list[_indexOf].used <= 0)	return false;
		// All right
		list[_indexOf].used--;
		refresh();
		return true;
	}
	
	public function entityClickHandler (_target:Entity) :Void {
		//trace("entityClickHandler: " + _target);
		if (index != -1)
			slots.getChildAt(index).play(InvSlot.OFF);
		index = slots.getChildIndex(_target);
		_target.play(InvSlot.ON);
	}
	
}

typedef InvObject = { type:LEType, variant:Int, count:Int, used:Int }

class InvSlot extends Entity
{
	
	static public var ON:String = "on";
	static public var OFF:String = "off";
	
	public var listIndex:Int;
	private var inventory:Inventory;
	private var entity:InvEntity;
	
	public function new (_inventory:Inventory) {
		super();
		
		listIndex = -1;
		inventory = _inventory;
		
		var _anim:Animation;
		_anim = new Animation(OFF, "tiles");
		_anim.addFrame(new AnimFrame("inv_slot_off"));
		anims.push(_anim);
		_anim = new Animation(ON, "tiles");
		_anim.addFrame(new AnimFrame("inv_slot_on"));
		anims.push(_anim);
		
		play(OFF);
	}
	
	public function display (_type:LEType, _variant:Int = 0) :Void {
		if (entity != null) {
			entity.destroy();
			removeChild(entity);
			entity == null;
		}
		if (_type != null) {
			entity = new InvEntity(_type, _variant, inventory);
			addChild(entity);
		}
	}
	
}










