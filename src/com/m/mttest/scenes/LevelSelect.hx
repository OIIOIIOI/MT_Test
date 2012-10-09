package com.m.mttest.scenes;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.display.BitmapText;
import com.m.mttest.display.Button;
import com.m.mttest.display.FastEntity;
import com.m.mttest.display.Lock;
import com.m.mttest.display.TutoPopup;
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
	private var back:Button;
	//private var sound:Button;
	
	public function new () {
		super();
		// Title
		title = new FastEntity("title_level_select");
		title.scale = 2;
		title.x = (Game.SIZE.width / Game.SCALE - title.width * title.scale) / 2;
		title.y = 12;
		addChild(title);
		// Home
		back = new Button(24, ButtonType.home);
		back.x = 8;
		back.y = Game.SIZE.height / Game.SCALE - back.height - 8;
		back.customClickHandler = entitiesClickHandler;
		addChild(back);
		// Mute
		/*sound = new Button(24, ButtonType.sound);
		sound.x = Game.SIZE.width / Game.SCALE - sound.width - 8;
		sound.y = Game.SIZE.height / Game.SCALE - sound.height - 8;
		sound.customClickHandler = entitiesClickHandler;
		addChild(sound);*/
		// Slots
		slots = new Entity();
		addChild(slots);
		//
		// Parse levels
		var _spacing:Int = 3;
		var _slot:LevelSlot;
		for (_i in 0...Game.LEVELS.length - 1) {
			_slot = new LevelSlot(_i);
			_slot.x = (_slot.width + _spacing) * (_i % 5);
			_slot.y = (_slot.height + _spacing) * Math.floor(_i / 5);
			slots.addChild(_slot);
			if (slots.width < _slot.width)		slots.width = 5 * (_slot.width + _spacing) - _spacing;
			if (slots.height < _slot.height)	slots.height = Math.ceil(Game.LEVELS.length / 5) * (_slot.height + _spacing) - _spacing;
			_slot.customClickHandler = entitiesClickHandler;
		}
		slots.x = (Game.SIZE.width / Game.SCALE - slots.width) / 2;
		slots.y = 12 + (Game.SIZE.height / Game.SCALE - slots.height) / 2;
	}
	
	public function entitiesClickHandler (_target:Entity) :Void {
		//trace("entitiesClickHandler: " + _target.index);
		if (Std.is(_target, LevelSlot)) {
			if (!Game.LEVELS[cast(_target, LevelSlot).index].locked)
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.play, param:cast(_target, LevelSlot).index } ));
		}
		else switch (_target) {
			case cast(back, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.startMenu } ));
			//case cast(sound, Entity): trace("MUTE");
		}
		
	}
	
}

class LevelSlot extends Entity
{
	
	static public var IDLE:String = "idle";
	
	public var index (default, null):Int;
	private var number:BitmapText;
	private var lock:Lock;
	
	public function new (_index:Int) {
		super();
		
		index = _index;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("level_slot" + Std.random(2), 0, 0, Std.random(2) == 0));
		anims.push(_anim);
		play(IDLE);
		
		if (!Game.LEVELS[index].locked) {
			if (Game.LEVELS[index].tuto != null)
				number = new BitmapText(Std.string(index + 1), "font_numbers_gold");
			else number = new BitmapText(Std.string(index + 1), "font_numbers_blue");
			number.mouseEnabled = false;
			number.x = (width - number.width) / 2;
			number.y = (height - number.height) / 2;
			addChild(number);
		}
		else {
			lock = new Lock();
			lock.mouseEnabled = false;
			lock.x = (width - lock.width) / 2;
			lock.y = (height - lock.height) / 2 - 1;
			addChild(lock);
		}
	}
	
}

typedef LevelObject = { name:String, locked:Bool, tuto:Tuto }








