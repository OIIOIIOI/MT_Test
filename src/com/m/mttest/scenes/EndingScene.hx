package com.m.mttest.scenes;

import com.m.mttest.display.Button;
import com.m.mttest.entities.Entity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.Game;

/**
 * ...
 * @author 01101101
 */

class EndingScene extends Scene
{
	
	private var back:Button;
	
	public function new () {
		super();
		trace("CONGRATS!");
		// Exit to menu
		back = new Button(18, ButtonType.levelSelect);
		back.x = 32;
		back.y = 32;
		back.customClickHandler = entitiesClickHandler;
		addChild(back);
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		switch (_target) {
			case cast(back, Entity):
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.levelSelect } ));
		}
	}
	
}