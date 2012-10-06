package com.m.mttest;

import com.m.mttest.display.BitmapText;
import com.m.mttest.display.Interface;
import com.m.mttest.entities.BasicBlock;
import com.m.mttest.entities.Entity;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.entities.Selection;
import com.m.mttest.entities.Sheep;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.fx.AdvancedFadeFX;
import com.m.mttest.fx.ColorBlinkFX;
import com.m.mttest.fx.ColorFX;
import com.m.mttest.fx.FadeFX;
import com.m.mttest.fx.ShakeFX;
import com.m.mttest.levels.Inventory;
import com.m.mttest.levels.Level;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import haxe.Timer;

/**
 * ...
 * @author 01101101
 */

using Lambda;
class Game extends Sprite
{
	
	inline static private var SIZE:Rectangle = new Rectangle(0, 0, 266, 160);// Since the display is at pixel-level, specify how much to scale it
	inline static private var SCALE:Int = 3;// Since the display is at pixel-level, specify how much to scale it
	inline static public var FPS:UInt = 40;// How many times per second do we want the game to update
	inline static public var MS:Float = 1000 / FPS;
	inline static public var TILE_SIZE:UInt = 16;// The size of a single tile
	
	private var canvas:Bitmap;// The display container
	private var canvasData:BitmapData;// The display data
	
	private var entities:Array<Entity>;// A list of all the entities to update
	
	private var scene:Entity;
	private var level:Level;
	private var GUI:Interface;
	
	private var inventory:Inventory;
	
	private var lastFrame:Float;// The last time the game was updated
	private var endGameTimer:Timer;
	
	public function new () {
		super();
		// Create the empty display data
		canvasData = new BitmapData(Std.int(SIZE.width), Std.int(SIZE.height), false, 0xE7E7E7);
		// Create the entity array
		entities = new Array<Entity>();
		// Wait for the sprite to be added to the display list
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init (_event:Event) :Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		// Create the display container and scale it
		canvas = new Bitmap(canvasData);
		canvas.scaleX = canvas.scaleY = SCALE;
		addChild(canvas);
		
		// Init scene
		scene = new Entity();
		//scene.x = scene.y = 8;
		entities.push(scene);
		
		//var _levelName:String = "tuto_basics";
		//var _levelName:String = "tuto_timer";
		var _levelName:String = "tuto_rock";
		level = new Level();
		level.load(_levelName);
		level.x = (SIZE.width - level.width) / 2;
		level.y = (SIZE.height - level.height) / 2;
		scene.addChild(level);
		// Inventory
		inventory = new Inventory();
		inventory.load(_levelName + "_inv");
		inventory.x = level.x + level.width;
		inventory.y = level.y;
		scene.addChild(inventory);
		// GUI
		GUI = new Interface();
		GUI.x = inventory.x + inventory.width;
		GUI.y = inventory.y;
		scene.addChild(GUI);
		
		// Start main loop
		lastFrame = 0;
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		// Click events
		stage.addEventListener(MouseEvent.CLICK, clickHandler);
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
					endGameTimer.stop();
					level.reset();
				}
			case GameEvent.RESET_LEVEL:
				endGameTimer.stop();
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
	
	private function enterFrameHandler (_event:Event) :Void {
		// Check if it's time to update the game (a frame has passed)
		//var _diff:Float = Date.now().getTime() - lastFrame;
		//trace(_diff + " / " + MS);
		if (Date.now().getTime() - lastFrame >= MS) {
			update();
			lastFrame = Date.now().getTime();
		}
	}
	
	private function update () :Void {
		// Update every entity
		for (_entity in entities)
			_entity.update();
		// Call the draw function
		draw();
	}
	
	private function draw () :Void {
		// Reset the display data
		canvasData.fillRect(canvasData.rect, 0xE7E7E7);
		// Draw entities
		for (_entity in entities) {
			drawEntity(_entity);
		}
	}
	
	private function drawEntity (_entity:Entity) :Void {
		var _matrix:Matrix = new Matrix();
		var _translateOffset:Point = new Point();
		var _mask:Rectangle = null;
		var _transform:ColorTransform = new ColorTransform();
		// Entity
		_translateOffset.x += _entity.absX + _entity.frameOffset.x;
		_translateOffset.y += _entity.absY + _entity.frameOffset.y;
		// Apply effects
		for (_fx in _entity.effects) {
			if (Std.is(_fx, ShakeFX)) {
				_translateOffset.x += cast(_fx, ShakeFX).offset.x;
				_translateOffset.y += cast(_fx, ShakeFX).offset.y;
			}
			else if (Std.is(_fx, FadeFX)) {
				_transform.alphaMultiplier *= cast(_fx, FadeFX).alpha;
			}
			else if (Std.is(_fx, AdvancedFadeFX)) {
				_transform.concat(cast(_fx, AdvancedFadeFX).transform);
			}
			else if (Std.is(_fx, ColorBlinkFX)) {
				if (cast(_fx, ColorBlinkFX).on) {
					_transform.concat(cast(_fx, ColorBlinkFX).transform);
				}
			}
			else if (Std.is(_fx, ColorFX)) {
				_transform.concat(cast(_fx, ColorFX).transform);
			}
		}
		_matrix.scale(_entity.absScale, _entity.absScale);
		_matrix.translate(Std.int(_translateOffset.x), Std.int(_translateOffset.y));
		_transform.alphaMultiplier *= _entity.alpha;
		// Mask
		if (_entity.mask != null) {
			_mask = _entity.mask.clone();
			_mask.x += _translateOffset.x;
			_mask.y += _translateOffset.y;
		}
		// Blend mode
		var _blendMode:BlendMode = _entity.blendMode;
		// Draw entity
		canvasData.draw(_entity.bitmapData, _matrix, _transform, _blendMode, _mask);
		// Draw entity's children
		for (_e in _entity.children) {
			drawEntity(_e);
		}
	}
	
	private function clickHandler (_event:MouseEvent) :Void {
		// Search targets
		var _point:Point = new Point(Std.int(_event.stageX / SCALE), Std.int(_event.stageY / SCALE));
		var _targets:Array<Entity> = getEntitiesAt(entities[0], Std.int(_point.x), Std.int(_point.y));
		//trace("clickHandler: " + _targets);
		if (_targets.length > 0) {
			var _target:Entity = _targets.pop();
			while (!_target.mouseEnabled) {
				if (_targets.length > 0)
					_target = _targets.pop();
				else {
					_target = null;
					break;
				}
			}
			if (_target != null)
				_target.clickHandler();
		}
	}
	
	private function getEntitiesAt (_entity:Entity, _x:Int, _y:Int) :Array<Entity> {
		var _targets:Array<Entity> = new Array<Entity>();
		if (_entity.hitTestPoint(new Point(_x, _y))) {
			//trace(Type.getClass(_entity));
			_targets.push(_entity);
		}
		for (_e in _entity.children) {
			_targets = _targets.concat(getEntitiesAt(_e, _x, _y));
		}
		return _targets;
	}
	
	private function checkEndGame (_fromTimer:Bool = true) :Void {
		//trace(level.endGameEntities);
		endGameTimer.stop();
		var _endGame:Bool = true;
		var _forceEndGame:Bool = false;
		var _victory:Bool = true;
		var _reason:String = "not all sheep arrived";
		for (_e in level.endGameEntities) {
			if (_e.type == LEType.sheep) {
				//trace("sheep state: " + cast(_e, Sheep).state);
				switch (cast(_e, Sheep).state) {
					case SheepState.dead:
						_reason = "dead sheep";
						_forceEndGame = _fromTimer;// Delay end game with timer
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










