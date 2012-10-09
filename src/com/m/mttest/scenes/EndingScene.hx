package com.m.mttest.scenes;

import com.m.mttest.display.BitmapText;
import com.m.mttest.display.Button;
import com.m.mttest.display.FastEntity;
import com.m.mttest.display.TextLayer;
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

class EndingScene extends Scene
{
	
	private var title:FastEntity;
	private var back:Button;
	
	public function new () {
		super();
		// Title
		title = new FastEntity("title_ending");
		title.scale = 2;
		title.x = (Game.SIZE.width / Game.SCALE - title.width * title.scale) / 2;
		title.y = 12;
		addChild(title);
		// Text
		var _array:Array<String> = new Array<String>();
		_array.push("You completed all the levels!");
		_array.push("You are a true master of explosive sheep-keeping.");
		_array.push(" ");
		_array.push("Stay tuned though, new levels may appear in the future...");
		_array.push("The Elder Shepherds sometimes tell stories, late at night,");
		_array.push("about an editor which would allow anyone to create levels!");
		_array.push(" ");
		_array.push("But you never know with these old buggers...");
		_array.push(" ");
		_array.push("Anyway, thanks for playing!");
		var _bt:BitmapText;
		for (_i in 0..._array.length) {
			_bt = new BitmapText(_array[_i]);
			_bt.scale = 2;
			_bt.x = (Game.SIZE.width - _bt.width) / 2;
			_bt.y = 130 + _i * 22;
			_bt.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 156, 107, 0)), true, true);
			TextLayer.instance.addChild(_bt);
			
		}
		var _sheep:DisplaySheep;
		for (_i in 0...3) {
			_sheep = new DisplaySheep();
			_sheep.x = (Game.SIZE.width / Game.SCALE / 2) + (_i - 1) * 32 - 8;
			_sheep.y = Game.SIZE.height / Game.SCALE - 28;
			switch (_i) {
				case 0:		_sheep.play(DisplaySheep.JUMP);
				case 1:		_sheep.play(DisplaySheep.IDLE);
				case 2:		_sheep.play(DisplaySheep.MOVING);
			}
			addChild(_sheep);
		}
		// Exit to menu
		back = new Button(24, ButtonType.home);
		back.x = 8;
		back.y = Game.SIZE.height / Game.SCALE - back.height - 8;
		back.customClickHandler = entitiesClickHandler;
		addChild(back);
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		switch (_target) {
			case cast(back, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.startMenu } ));
		}
	}
	
}