package com.m.mttest.scenes;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.display.BitmapText;
import com.m.mttest.display.FastEntity;
import com.m.mttest.display.Lock;
import com.m.mttest.entities.Entity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.Game;

/**
 * ...
 * @author 01101101
 */

class LevelSelect extends Scene
{
	
	private var slots:Entity;
	private var title:FastEntity;
	private var back:FastEntity;
	private var sound:FastEntity;
	
	public function new () {
		super();
		
		title = new FastEntity("title_level_select");
		title.scale = 2;
		title.x = (Game.SIZE.width - title.width * title.scale) / 2;
		title.y = 12;
		addChild(title);
		
		back = new FastEntity("button_home_22");
		back.x = 8;
		back.y = Game.SIZE.height - back.height - 8;
		addChild(back);
		
		sound = new FastEntity("button_sound_on");
		sound.x = Game.SIZE.width - sound.width - 8;
		sound.y = Game.SIZE.height - sound.height - 8;
		addChild(sound);
		
		slots = new Entity();
		addChild(slots);
		
		var _slot:LevelSlot;
		for (_i in 0...Game.LEVELS.length) {
			_slot = new LevelSlot(_i, this);
			_slot.x = (_slot.width + 1) * _i;
			slots.addChild(_slot);
			slots.width += _slot.width + 1;
			if (_slot.height > slots.height)	slots.height = _slot.height;
		}
		slots.width--;
		slots.x = (Game.SIZE.width - slots.width) / 2;
		slots.y = (Game.SIZE.height - slots.height) / 2;
	}
	
	public function entityClickHandler (_target:LevelSlot) :Void {
		//trace("entityClickHandler: " + _target.index);
		if (!Game.LEVELS[_target.index].locked)
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.play, param:_target.index } ));
	}
	
}

class LevelSlot extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public var index (default, null):Int;
	private var scene:LevelSelect;
	private var number:BitmapText;
	private var lock:Lock;
	
	public function new (_index:Int, _scene:LevelSelect) {
		super();
		
		index = _index;
		scene = _scene;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("level_slot" + Std.random(2), 0, 0, Std.random(2) == 0));
		anims.push(_anim);
		play(IDLE);
		
		if (!Game.LEVELS[index].locked) {
			number = new BitmapText(Std.string(index + 1), "font_numbers_gold");
			number.mouseEnabled = false;
			//number.scale = 2;
			number.x = (width - number.width) / 2 + 1;
			number.y = (height - number.height) / 2;
			addChild(number);
		}
		else {
			lock = new Lock();
			lock.mouseEnabled = false;
			lock.x = (width - lock.width) / 2;
			lock.y = (height - lock.height) / 2;
			addChild(lock);
		}
	}
	
	override public function clickHandler () :Void {
		scene.entityClickHandler(this);
	}
	
}

typedef LevelObject = { name:String, locked:Bool }








