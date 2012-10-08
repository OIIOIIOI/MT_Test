package com.m.mttest.scenes;

import com.m.mttest.display.FastEntity;
import com.m.mttest.display.Interface;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.entities.Sheep;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.Game;
import com.m.mttest.levels.Inventory;
import com.m.mttest.levels.Level;
import haxe.Timer;

/**
 * ...
 * @author 01101101
 */

class Play extends Scene
{
	
	private var level:Level;
	private var GUI:Interface;
	private var inventory:Inventory;
	private var pauseButton:FastEntity;
	
	private var index:Int;
	private var endGameTimer:Timer;
	
	public function new (_index:Int) {
		super();
		// Pause
		pauseButton = new FastEntity("button_pause");
		pauseButton.x = Game.SIZE.width / Game.SCALE - pauseButton.width - 4;
		//pauseButton.y = Game.SIZE.height / Game.SCALE - pauseButton.height - 4;
		pauseButton.y = 4;
		addChild(pauseButton);
		// Init
		index = Std.int(Math.min(Math.max(_index, 0), Game.LEVELS.length - 1));
		init(Game.LEVELS[index].name);
	}
	
	private function init (_level:String) :Void {
		// Load level
		level = new Level();
		level.load(_level);
		level.x = (Game.SIZE.width / Game.SCALE - level.width) / 2;
		level.y = (Game.SIZE.height / Game.SCALE - level.height) / 2 - 2;
		addChild(level);
		// Load inventory
		inventory = new Inventory();
		inventory.load(_level + "_inv");
		inventory.x = level.x + level.width - 10;
		inventory.y = (Game.SIZE.height / Game.SCALE - inventory.height) / 2;
		inventory.refresh();
		addChild(inventory);
		// GUI
		GUI = new Interface();
		GUI.x = inventory.x + inventory.width + 2;
		GUI.y = inventory.y;
		addChild(GUI);
		
		// Game events
		EventManager.instance.addEventListener(GameEvent.PLAY_LEVEL, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.RESET_LEVEL, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.PLACE_ITEM, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.REMOVE_ITEM, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.SHEEP_DIED, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.SHEEP_ARRIVED, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.BOMB_EXPLODED, gameEventHandler);
	}
	
	private function gameEventHandler (_event:GameEvent) :Void {
		switch (_event.type) {
			case GameEvent.PLAY_LEVEL:
				if (!level.active) {
					level.activate();
					endGameTimer = Timer.delay(callback(checkEndGame), 1500);
				}
				else {
					if (endGameTimer != null)	endGameTimer.stop();
					level.reset();
				}
			case GameEvent.RESET_LEVEL:
				if (endGameTimer != null)	endGameTimer.stop();
				level.reset(true);
				inventory.reset();
			case GameEvent.PLACE_ITEM:
				var _invObject:InvObject = inventory.getSelected();
				if (inventory.useItem(_invObject))
					level.placeItem(_invObject, _event.data);
			case GameEvent.REMOVE_ITEM:
				var _entity:LevelEntity = cast(_event.data, LevelEntity);
				if (inventory.putBackItem(_entity.type, _entity.variant))
					level.removeItem(_entity);
			case GameEvent.SHEEP_DIED, GameEvent.SHEEP_ARRIVED, GameEvent.BOMB_EXPLODED:
				//trace("END GAME EVENT: " + _event.type.toUpperCase());
				checkEndGame(false);
		}
	}
	
	private function checkEndGame (_fromTimer:Bool = true) :Void {
		//trace(level.endGameEntities);
		endGameTimer.stop();
		var _endGame:Bool = true;
		var _forceEndGame:Bool = false;
		var _victory:Bool = true;
		var _reason:String = "Some sheep did not make it...";
		for (_e in level.endGameEntities) {
			if (_e.type == LEType.sheep) {
				//trace("sheep state: " + cast(_e, Sheep).state);
				switch (cast(_e, Sheep).state) {
					case SheepState.dead, SheepState.fallen:
						_reason = "A sheep was injured...";
						_forceEndGame = _fromTimer;// Delay end game with timer
						_endGame = false;
						_victory = false;
					case SheepState.asleep:
						if (!_fromTimer) _endGame = false;// Verification is not coming from the timer
						_victory = false;
					case SheepState.moving:
						_endGame = false;// Sheep still moving
						_victory = false;
					case SheepState.arrived: {}
				}
			}
			else if (_e.type == LEType.bomb) {
				//trace("bomb active: " + _e.active);
				if (_e.active)	_endGame = false;// Bomb still active
			}
		}
		//trace("END GAME: " + _endGame + " / VICTORY: " + _victory);
		if (_endGame || _forceEndGame)	endGame(_victory, _reason);
		else							endGameTimer = Timer.delay(callback(checkEndGame), 1500);
	}
	
	private function endGame (_victory:Bool, _reason:String) :Void {
		// TODO Stop updating level and entities
		level.paused = true;
		if (_victory)	trace("VICTORY!");
		else			trace("FAIL! " + _reason.toUpperCase());
		//
	}
	
}