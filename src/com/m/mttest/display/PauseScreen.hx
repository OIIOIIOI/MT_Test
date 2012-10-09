package com.m.mttest.display;

import com.m.mttest.display.Button;
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

class PauseScreen extends Entity
{
	
	private var title:FastEntity;
	private var back:Button;
	private var sound:Button;
	
	public function new () {
		super();
		// Background
		//color = 0xCC00000F;
		color = 0xBBF2F9FF;
		//color = 0xCC3D454D;
		width = Std.int(Game.SIZE.width / Game.SCALE);
		height = Std.int(Game.SIZE.height / Game.SCALE);
		// Title
		title = new FastEntity("title_pause");
		title.scale = 2;
		title.x = (Game.SIZE.width / Game.SCALE - title.width * title.scale) / 2;
		title.y = 12;
		addChild(title);
		//
		// Sound
		sound = new Button(999, ButtonType.sound);
		sound.x = (Game.SIZE.width / Game.SCALE - sound.width) /2;
		sound.y = (Game.SIZE.height / Game.SCALE - (sound.height * 2 + 4)) / 2;
		sound.customClickHandler = entitiesClickHandler;
		addChild(sound);
		// Sound label
		var _label:BitmapText = new BitmapText("Toggle sound");
		_label.mouseEnabled = false;
		_label.x = sound.height + 2;
		_label.y = (sound.height - _label.height) / 2;
		_label.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 80, 50, 25)), true, true);
		sound.addChild(_label);
		//
		// Exit to menu
		back = new Button(999, ButtonType.levelSelect);
		back.x = sound.x;
		back.y = sound.y + sound.height + 4;
		back.customClickHandler = entitiesClickHandler;
		addChild(back);
		// Exit label
		_label = new BitmapText("Exit level");
		_label.mouseEnabled = false;
		_label.x = back.height + 2;
		_label.y = (back.height - _label.height) / 2 - 1;
		_label.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 80, 50, 25)), true, true);
		back.addChild(_label);
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		switch (_target) {
			case cast(back, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.levelSelect } ));
			case cast(sound, Entity): trace("MUTE");
		}
	}
	
}
