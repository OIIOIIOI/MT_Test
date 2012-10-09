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

class EndGameScreen extends Entity
{
	
	private var title:FastEntity;
	private var back:Button;
	private var replay:Button;
	private var next:Button;
	
	public function new (_victory:Bool, ?_reason:String, _unlock:Bool = false) {
		super();
		// Background
		//color = 0xCC00000F;
		color = 0xBBF2F9FF;
		width = Std.int(Game.SIZE.width / Game.SCALE);
		height = Std.int(Game.SIZE.height / Game.SCALE);
		// Title
		title = (_victory) ? new FastEntity("title_cleared") : new FastEntity("title_failed");
		title.scale = 2;
		title.x = (Game.SIZE.width / Game.SCALE - title.width * title.scale) / 2;
		title.y = 12;
		addChild(title);
		// Exit to menu
		back = new Button(18, ButtonType.levelSelect);
		back.x = 32;
		back.y = Game.SIZE.height / Game.SCALE - back.height - 32;
		back.customClickHandler = entitiesClickHandler;
		addChild(back);
		// Replay
		if (_victory)	replay = new Button(18, ButtonType.reset);
		else			replay = new Button(24, ButtonType.reset);
		replay.icon.play("on");
		replay.x = back.x + back.width + 4;
		replay.y = back.y + (back.height - replay.height) / 2;
		replay.customClickHandler = entitiesClickHandler;
		addChild(replay);
		// Next (display if next level is unlocked or this was the last level
		if ((Game.CURRENT_LEVEL + 1 < Game.LEVELS.length && !Game.LEVELS[Game.CURRENT_LEVEL + 1].locked)
			|| (_victory && Game.CURRENT_LEVEL + 1 >= Game.LEVELS.length))
		{
			// Big if victory
			if (_victory)	next = new Button(24, ButtonType.next);
			else			next = new Button(18, ButtonType.next);
			next.x = replay.x + replay.width + 4;
			next.y = replay.y + (replay.height - next.height) / 2;
			next.customClickHandler = entitiesClickHandler;
			addChild(next);
		}
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		switch (_target) {
			case cast(replay, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.RESET_LEVEL));
			case cast(back, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.levelSelect } ));
			case cast(next, Entity):
				if (Game.CURRENT_LEVEL + 1 >= Game.LEVELS.length)
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.ending} ));
				else
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.play, param:Game.CURRENT_LEVEL + 1 } ));
		}
	}
	
}
