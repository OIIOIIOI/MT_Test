package com.m.mttest.display;

import com.m.mttest.entities.Entity;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;

/**
 * ...
 * @author 01101101
 */

class Interface extends Entity
{
	
	public var playButton (default, null):PlayLevelButton;
	public var resetButton (default, null):ResetLevelButton;
	
	public function new () {
		super();
		
		playButton = new PlayLevelButton(this);
		
		resetButton = new ResetLevelButton(this);
		resetButton.y = 16;
		
		addChild(playButton);
		addChild(resetButton);
	}
	
	public function entityClickHandler (_target:Entity) :Void {
		if (_target == playButton) {
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.PLAY_LEVEL));
		}
		else if (_target == resetButton) {
			playButton.play(PlayLevelButton.PLAY);
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.RESET_LEVEL));
		}
	}
	
}
