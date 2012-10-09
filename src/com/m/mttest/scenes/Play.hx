package com.m.mttest.scenes;

import com.m.mttest.display.Button;
import com.m.mttest.display.EndGameScreen;
import com.m.mttest.display.FastEntity;
import com.m.mttest.display.PauseScreen;
import com.m.mttest.display.TextLayer;
import com.m.mttest.display.TutoPopup;
import com.m.mttest.entities.Entity;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.entities.Sheep;
import com.m.mttest.entities.ShineFX;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.fx.ColorBlinkFX;
import com.m.mttest.Game;
import com.m.mttest.levels.Inventory;
import com.m.mttest.levels.Level;
import flash.geom.ColorTransform;
import flash.geom.Point;
import haxe.Timer;

/**
 * ...
 * @author 01101101
 */

class Play extends Scene
{
	
	private var level:Level;
	private var inventory:Inventory;
	private var pauseButton:Button;
	private var playButton:Button;
	private var resetButton:Button;
	//private var bottomBG:Entity;
	private var shineFX:ShineFX;
	//private var hint:Hint;
	private var failLayer:Entity;
	private var pauseScreen:PauseScreen;
	private var endGameScreen:EndGameScreen;
	private var tutoPopup:TutoPopup;
	
	private var endGameTimer:Timer;
	private var locked (default, setLocked):Bool;
	private var timerCallback:Dynamic;
	
	public function new (_index:Int) {
		super();
		//
		Game.CURRENT_LEVEL = Std.int(Math.min(Math.max(_index, 0), Game.LEVELS.length - 1));
		// Pause
		pauseButton = new Button(22, ButtonType.pause);
		pauseButton.x = 3;
		pauseButton.y = Game.SIZE.height / Game.SCALE - pauseButton.height - 3;
		pauseButton.customClickHandler = entitiesClickHandler;
		// Start/stop
		playButton = new Button(24, ButtonType.startStop);
		playButton.x = Game.SIZE.width / Game.SCALE - playButton.width - 2;
		playButton.y = Game.SIZE.height / Game.SCALE - playButton.height - 2;
		playButton.customClickHandler = entitiesClickHandler;
		// Reset
		resetButton = new Button(18, ButtonType.reset);
		resetButton.x = playButton.x - resetButton.width - 2;
		resetButton.y = playButton.y + (playButton.height - resetButton.height) / 2;
		resetButton.customClickHandler = entitiesClickHandler;
		// Shine FX
		shineFX = new ShineFX();
		shineFX.mouseEnabled = false;
		shineFX.x = playButton.icon.absX;
		shineFX.y = playButton.icon.absY;
		// Hint
		//hint = new Hint();
		//hint.y = 4;
		//TextLayer.instance.addChild(hint);
		// Init
		init(Game.LEVELS[Game.CURRENT_LEVEL].name);
	}
	
	private function setLocked (_locked:Bool) :Bool {
		locked = _locked;
		if (_locked) {
			pauseButton.mouseEnabled = playButton.mouseEnabled = resetButton.mouseEnabled = false;
		}
		else {
			pauseButton.mouseEnabled = playButton.mouseEnabled = resetButton.mouseEnabled = true;
		}
		return locked;
	}
	
	private function init (_level:String) :Void {
		// Load level
		level = new Level();
		level.load(_level);
		level.x = (Game.SIZE.width / Game.SCALE - level.width) / 2;
		level.y = (Game.SIZE.height / Game.SCALE - level.height) / 2 - 10;
		// Load inventory
		inventory = new Inventory();
		inventory.load(_level + "_inv");
		inventory.x = (Game.SIZE.width / Game.SCALE - inventory.width) / 2;
		inventory.y = Game.SIZE.height / Game.SCALE - inventory.height - 2;
		// Bottom background
		//bottomBG = new Entity();
		//bottomBG.color = 0x66F2F9FF;
		//bottomBG.width = Std.int(Game.SIZE.width / Game.SCALE);
		//bottomBG.height = Std.int(Math.max(playButton.height, inventory.height) + 4);
		//bottomBG.y = Game.SIZE.height / Game.SCALE - bottomBG.height;
		// Adds
		addChild(level);
		//addChild(bottomBG);
		addChild(inventory);
		addChild(resetButton);
		addChild(playButton);
		addChild(pauseButton);
		// Fail layer
		failLayer = new Entity();
		addChild(failLayer);
		// Tuto
		if (Game.LEVELS[Game.CURRENT_LEVEL].tuto != null) {
			
			tutoPopup = new TutoPopup(Game.LEVELS[Game.CURRENT_LEVEL].tuto);
			TextLayer.instance.addChild(tutoPopup);
			EventManager.instance.addEventListener(GameEvent.EXIT_TUTO, gameEventHandler);
		}
		// Game events
		EventManager.instance.addEventListener(GameEvent.RESET_LEVEL, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.PLACE_ITEM, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.REMOVE_ITEM, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.SHEEP_DIED, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.SHEEP_ARRIVED, gameEventHandler);
		EventManager.instance.addEventListener(GameEvent.BOMB_EXPLODED, gameEventHandler);
	}
	
	private function gameEventHandler (_event:GameEvent) :Void {
		switch (_event.type) {
			case GameEvent.EXIT_TUTO:
				EventManager.instance.removeEventListener(GameEvent.EXIT_TUTO, gameEventHandler);
				TextLayer.instance.removeChild(tutoPopup);
				tutoPopup.destroy();
				tutoPopup = null;
			case GameEvent.RESET_LEVEL:
				resetLevel(true);
			case GameEvent.PLACE_ITEM:
				var _invObject:InvObject = inventory.getSelected();
				if (inventory.useItem(_invObject)) {
					level.placeItem(_invObject, _event.data);
					resetButton.icon.play("on");
					// Add FX
					if (inventory.getSelected() == null) {
						addChild(shineFX);
						playButton.addFX(new ColorBlinkFX(-1, new ColorTransform(1, 1, 1, 1, 32, 32, 32), null, 4));
					}
				}
			case GameEvent.REMOVE_ITEM:
				var _entity:LevelEntity = cast(_event.data, LevelEntity);
				if (inventory.putBackItem(_entity.type, _entity.variant)) {
					level.removeItem(_entity);
					// Remove FX
					removeChild(shineFX);
					playButton.removeFX();
					// If no item used
					if (inventory.getUsed() == 0) {
						resetButton.icon.play("off");
					}
				}
			case GameEvent.SHEEP_DIED, GameEvent.SHEEP_ARRIVED, GameEvent.BOMB_EXPLODED:
				//trace("END GAME EVENT: " + _event.type.toUpperCase());
				checkEndGame(false);
		}
	}
	
	private function entitiesClickHandler (_target:Entity) :Void {
		if (locked)	return;// Just for safety
		switch (_target) {
			case cast(pauseButton, Entity):
				pauseGame(!level.paused);
			case cast(playButton, Entity):
				if (!level.active) {
					// Remove FX
					removeChild(shineFX);
					playButton.removeFX();
					//
					inventory.locked = true;
					level.activate();
					endGameTimer = Timer.delay(callback(checkEndGame), 1500);
				}
				else {
					// Add FX
					if (inventory.getSelected() == null) {
						addChild(shineFX);
						playButton.addFX(new ColorBlinkFX(-1, new ColorTransform(1, 1, 1, 1, 32, 32, 32), null, 4));
					}
					//
					inventory.locked = false;
					if (endGameTimer != null)	endGameTimer.stop();
					level.reset();
				}
			case cast(resetButton, Entity):
				// Remove FX
				removeChild(shineFX);
				playButton.removeFX();
				//
				resetLevel();
		}
	}
	
	private function resetLevel (_force:Bool = false) :Void {
		if (!_force && resetButton.icon.currentAnimName == "off")
			return;
		// Timer
		if (endGameTimer != null)
			endGameTimer.stop();
		// Level
		level.reset(true);
		// Inventory
		inventory.reset();
		if (inventory.locked)
			inventory.locked = false;
		// GUI
		playButton.icon.play("play");
		resetButton.icon.play("off");
		// End game screen
		if (endGameScreen != null) {
			removeChild(endGameScreen);
			endGameScreen.destroy();
			endGameScreen = null;
		}
		// Lock
		if (locked)	locked = false;
		// Pause
		if (level.paused)
			pauseGame(false);
	}
	
	private function pauseGame (_pause:Bool = true) :Void {
		level.paused = _pause;
		EventManager.instance.dispatchEvent(new GameEvent(GameEvent.LEVEL_PAUSED, _pause));
		if (pauseScreen == null)
			pauseScreen = new PauseScreen();
		if (_pause) {
			if (endGameTimer != null) {
				timerCallback = endGameTimer.run;
				endGameTimer.stop();
				endGameTimer = null;
			}
			//TextLayer.instance.removeChild(hint);
			addChild(pauseScreen);
			addChild(pauseButton);
		}
		else {
			if (timerCallback != null) {
				endGameTimer = Timer.delay(timerCallback, 1000);
				timerCallback = null;
			}
			removeChild(pauseScreen);
			//TextLayer.instance.addChild(hint);
		}
	}
	
	private function checkEndGame (_fromTimer:Bool = true) :Void {
		//trace(level.endGameEntities);
		endGameTimer.stop();
		//
		var _endGame:Bool = true;
		var _forceEndGame:Bool = false;
		var _victory:Bool = true;
		var _reason:Int = -1;
		var _failTargets:Array<Point> = new Array<Point>();
		// Loop
		for (_e in level.endGameEntities) {
			if (_e.type == LEType.sheep) {
				//trace("sheep state: " + cast(_e, Sheep).state);
				switch (cast(_e, Sheep).state) {
					case SheepState.dead, SheepState.fallen:
						if (_reason <= 0)	_reason = 1;// One
						else				_reason = 2;// Several
						_forceEndGame = _fromTimer;// Delay end game with timer
						_endGame = false;
						_victory = false;
						_failTargets.push(new Point(_e.absX, _e.absY));
					case SheepState.asleep:
						if (!_fromTimer) _endGame = false;// Verification is not coming from the timer
						_victory = false;
						if (_reason == -1)	_reason = 0;
						_failTargets.push(new Point(_e.absX, _e.absY));
					case SheepState.moving:
						_endGame = false;// Sheep still moving
						_victory = false;
					case SheepState.arrived: { };
				}
			}
			else if (_e.type == LEType.bomb) {
				//trace("bomb active: " + _e.active);
				if (_e.active)	_endGame = false;// Bomb still active
			}
		}
		//trace("END GAME: " + _endGame + " / VICTORY: " + _victory);
		if (_endGame || _forceEndGame) {
			locked = true;
			showFailTargets(_failTargets);
			endGame(_victory, _reason);
		}
		else {
			endGameTimer = Timer.delay(callback(checkEndGame), 1500);
		}
	}
	
	private function showFailTargets (_targets:Array<Point>) :Void {
		var _fail:FastEntity;
		for (_p in _targets) {
			_fail = new FastEntity("fail_target");
			_fail.x = _p.x + (16 - _fail.width) / 2;
			_fail.y = _p.y + (16 - _fail.height) / 2;
			_fail.addFX(new ColorBlinkFX(-1, null, null, 6));
			failLayer.addChild(_fail);
		}
	}
	
	private function endGame (_victory:Bool, _reason:Int) :Void {
		// Unlock next level
		var _unlock:Bool = false;
		if (_victory) {
			_unlock = Game.unlockLevel(Game.CURRENT_LEVEL + 1);
			//trace("unlocked level " + (Game.CURRENT_LEVEL + 1));
		}
		// End game screen
		endGameScreen = new EndGameScreen(_victory, _reason, _unlock);
		if (_victory)	endGameTimer = Timer.delay(showEndGame, 500);
		else			endGameTimer = Timer.delay(showEndGame, 2000);
	}
	
	private function showEndGame () :Void {
		endGameTimer = null;
		level.paused = true;
		EventManager.instance.dispatchEvent(new GameEvent(GameEvent.LEVEL_PAUSED, true));
		addChild(endGameScreen);
		endGameScreen.addedToScene();
		while (failLayer.numChildren > 0) {
			failLayer.removeChildAt(0);
		}
	}
	
	override public function destroy () :Void {
		EventManager.instance.removeEventListener(GameEvent.RESET_LEVEL, gameEventHandler);
		EventManager.instance.removeEventListener(GameEvent.PLACE_ITEM, gameEventHandler);
		EventManager.instance.removeEventListener(GameEvent.REMOVE_ITEM, gameEventHandler);
		EventManager.instance.removeEventListener(GameEvent.SHEEP_DIED, gameEventHandler);
		EventManager.instance.removeEventListener(GameEvent.SHEEP_ARRIVED, gameEventHandler);
		EventManager.instance.removeEventListener(GameEvent.BOMB_EXPLODED, gameEventHandler);
		super.destroy();
	}
	
}