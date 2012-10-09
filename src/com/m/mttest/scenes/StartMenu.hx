package com.m.mttest.scenes;

import com.m.mttest.display.BitmapText;
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

class StartMenu extends Scene
{
	
	private var levelSelect:Button;
	private var sound:Button;
	
	public function new () {
		super();
		
		// Play
		levelSelect = new Button(999, ButtonType.levelSelect);
		levelSelect.x = (Game.SIZE.width / Game.SCALE - levelSelect.width) /2;
		levelSelect.y = (Game.SIZE.height / Game.SCALE - levelSelect.height) * 0.66;
		levelSelect.customClickHandler = entitiesClickHandler;
		addChild(levelSelect);
		// Play label
		var _label:BitmapText = new BitmapText("Play");
		_label.mouseEnabled = false;
		_label.x = levelSelect.height + 2;
		_label.y = (levelSelect.height - _label.height) / 2;
		_label.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 80, 50, 25)), true, true);
		levelSelect.addChild(_label);
		// Mute
		sound = new Button(24, ButtonType.sound);
		sound.x = Game.SIZE.width / Game.SCALE - sound.width - 8;
		sound.y = Game.SIZE.height / Game.SCALE - sound.height - 8;
		sound.customClickHandler = entitiesClickHandler;
		addChild(sound);
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		switch (_target) {
			case cast(levelSelect, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.levelSelect } ));
			case cast(sound, Entity): trace("MUTE");
		}
	}
	
}