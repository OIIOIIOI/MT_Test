package com.m.mttest.scenes;

import com.m.mttest.display.BitmapText;
import com.m.mttest.display.Button;
import com.m.mttest.display.FastEntity;
import com.m.mttest.entities.DisplaySheep;
import com.m.mttest.entities.Entity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.fx.ColorFX;
import com.m.mttest.Game;
import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class StartMenu extends Scene
{
	
	private var logo:FastEntity;
	private var levelSelect:Button;
	//private var sound:Button;
	private var credits:FastEntity;
	
	public function new () {
		super();
		
		// Logo
		logo = new FastEntity("title_logo");
		logo.x = (Game.SIZE.width / Game.SCALE - logo.width) /2;
		logo.y = 24;
		addChild(logo);
		// Sheep
		var _sheep:DisplaySheep;
		var _sheepArray:Array<DisplaySheep> = new Array<DisplaySheep>();
		//for (_i in 0...7) {
		for (_i in 0...countSheep()) {
			_sheep = new DisplaySheep();
			_sheep.x = (Game.SIZE.width / Game.SCALE / 2) + Std.random(200) - 100;
			_sheep.y = 48 + Std.random(10);
			switch (Std.random(3)) {
				default:	_sheep.play(DisplaySheep.IDLE);
				case 0:	_sheep.play(DisplaySheep.JUMP);
				case 1:	_sheep.play(DisplaySheep.MOVING);
			}
			_sheepArray.push(_sheep);
		}
		_sheepArray.sort(zSorting);
		for (_s in _sheepArray) {
			addChild(_s);
		}
		// Play
		levelSelect = new Button(24, ButtonType.startStop);
		levelSelect.x = (Game.SIZE.width / Game.SCALE - levelSelect.width) /2;
		levelSelect.y = (Game.SIZE.height / Game.SCALE - levelSelect.height) * 0.8;
		levelSelect.customClickHandler = entitiesClickHandler;
		addChild(levelSelect);
		// Play label
		/*var _label:BitmapText = new BitmapText("Play");
		_label.mouseEnabled = false;
		_label.x = levelSelect.height + 2;
		_label.y = (levelSelect.height - _label.height) / 2;
		_label.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 80, 50, 25)), true, true);
		levelSelect.addChild(_label);*/
		// Mute
		/*sound = new Button(24, ButtonType.sound);
		sound.x = Game.SIZE.width / Game.SCALE - sound.width - 8;
		sound.y = Game.SIZE.height / Game.SCALE - sound.height - 8;
		sound.customClickHandler = entitiesClickHandler;
		addChild(sound);*/
		credits = new FastEntity("credit");
		credits.x = (Game.SIZE.width / Game.SCALE - credits.width) / 2;
		credits.y = Game.SIZE.height / Game.SCALE - credits.height - 4;
		addChild(credits);
	}
	
	private function countSheep () :Int {
		var _count:Int = 0;
		for (_i in 1...Game.LEVELS.length) {
			if (!Game.LEVELS[_i].locked)	_count += Game.LEVELS[_i-1].sheep;
		}
		return _count;
	}
	
	private function zSorting (_e1:DisplaySheep, _e2:DisplaySheep) :Int {
		if (_e1.y > _e2.y)		return 1;
		else if (_e1.y < _e2.y)	return -1;
		else					return 0;
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		switch (_target) {
			case levelSelect:
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.levelSelect } ));
			//case cast(sound, Entity): trace("MUTE");
		}
	}
	
}