package com.m.mttest;

import com.m.mttest.anim.FrameManager;
import com.m.mttest.display.BitmapText;
import com.m.mttest.display.TextLayer;
import com.m.mttest.display.TutoPopup;
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
import com.m.mttest.scenes.EndingScene;
import com.m.mttest.scenes.LevelSelect;
import com.m.mttest.scenes.Play;
import com.m.mttest.scenes.StartMenu;
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
	
	inline static public var SIZE:Rectangle = new Rectangle(0, 0, 798, 480);// Since the display is at pixel-level, specify how much to scale it
	inline static public var SCALE:Int = 3;// Since the display is at pixel-level, specify how much to scale it
	inline static public var FPS:UInt = 40;// How many times per second do we want the game to update
	inline static public var MS:Float = 1000 / FPS;
	inline static public var TILE_SIZE:UInt = 16;// The size of a single tile
	
	static public var LEVELS:Array<LevelObject>;
	static public var CURRENT_LEVEL:Int;
	
	private var canvas:Bitmap;// The display container
	private var backgroundData:BitmapData;
	private var canvasData:BitmapData;
	private var scaledCanvasData:BitmapData;// The display data
	
	private var scene:Entity;
	
	private var lastFrame:Float;// The last time the game was updated
	
	public function new () {
		super();
		
		if (LEVELS == null) {
			LEVELS = new Array<LevelObject>();
			LEVELS.push( { name:"tuto_start", locked:false, tuto:Tuto.tutoStart } );
			LEVELS.push( { name:"tuto_rock", locked:false, tuto:Tuto.tutoRock } );
			LEVELS.push( { name:"tuto_time", locked:false, tuto:Tuto.tutoTime } );
			LEVELS.push( { name:"level_diag", locked:false, tuto:null } );
			LEVELS.push( { name:"tuto_hole", locked:false, tuto:Tuto.tutoHole } );
			LEVELS.push( { name:"level_minefield", locked:false, tuto:null } );
			LEVELS.push( { name:"tuto_big", locked:false, tuto:Tuto.tutoBigBomb } );
			LEVELS.push( { name:"level_big_time", locked:false, tuto:null } );
			LEVELS.push( { name:"tuto_chain", locked:false, tuto:Tuto.tutoChain } );
			LEVELS.push( { name:"level_mayhem", locked:false, tuto:null } );
			LEVELS.push( { name:"level_heart", locked:false, tuto:null } );
			//LEVELS.push( { name:"sandbox", locked:false, tuto:null } );
		}
		CURRENT_LEVEL = -1;
		// Create the empty display data
		canvasData = new BitmapData(Std.int(SIZE.width / SCALE), Std.int(SIZE.height / SCALE), false, 0xF2F9FF);
		scaledCanvasData = new BitmapData(Std.int(SIZE.width), Std.int(SIZE.height), false, 0xF2F9FF);
		backgroundData = FrameManager.getFrame("main_background", "background");
		// Wait for the sprite to be added to the display list
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	static public function unlockLevel (_index:Int) :Bool {
		// If invalid index or level already unlocked
		if (_index < 0 || _index >= LEVELS.length || !LEVELS[_index].locked)
			return false;
		// else, success
		LEVELS[_index].locked = false;
		return true;
	}
	
	private function init (_event:Event) :Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		// Create the display container and scale it
		canvas = new Bitmap(scaledCanvasData);
		addChild(canvas);
		
		// Init scene
		changeScene(GameScene.startMenu);
		//changeScene(GameScene.levelSelect);
		//changeScene(GameScene.ending);
		
		// Start main loop
		lastFrame = 0;
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		// Click events
		stage.addEventListener(MouseEvent.CLICK, clickHandler);
		// Game events
		EventManager.instance.addEventListener(GameEvent.CHANGE_SCENE, gameEventHandler);
	}
	
	private function gameEventHandler (_event:GameEvent) :Void {
		switch (_event.type) {
			case GameEvent.CHANGE_SCENE:
				changeScene(_event.data.scene, _event.data.param);
		}
	}
	
	private function changeScene (_scene:GameScene, ?_param:Dynamic) :Void {
		// Destroy current scene
		if (scene != null)	scene.destroy();
		while(TextLayer.instance.numChildren > 0) {
			TextLayer.instance.removeChildAt(0);
		}
		// Default scene
		if (_scene == null)	_scene = GameScene.startMenu;
		// Create new scene
		scene = switch (_scene) {
			case GameScene.startMenu:	new StartMenu();
			case GameScene.levelSelect: new LevelSelect();
			case GameScene.play:		new Play(_param);
			case GameScene.ending:	new EndingScene();
		}
		/*// TODO Play music (make music)
		if (scene.theme != null)
			playTheme(scene.theme);*/
	}
	
	private function enterFrameHandler (_event:Event) :Void {
		// Check if it's time to update the game (a frame has passed)
		if (Date.now().getTime() - lastFrame >= MS) {
			update();
			lastFrame = Date.now().getTime();
		}
	}
	
	private function update () :Void {
		if (scene == null)	return;
		// Update every entity
		for (_entity in scene.children)
			_entity.update();
		// Call the draw function
		draw();
	}
	
	private function draw () :Void {
		// Reset the display data
		canvasData.fillRect(canvasData.rect, 0xF2F9FF);
		canvasData.copyPixels(backgroundData, backgroundData.rect, new Point());
		// Draw entities
		for (_entity in scene.children) {
			drawEntity(_entity, canvasData);
		}
		// Scale up
		var _matrix:Matrix = new Matrix();
		_matrix.scale(3, 3);
		scaledCanvasData.draw(canvasData, _matrix);
		// Draw entities
		for (_entity in TextLayer.instance.children) {
			drawEntity(_entity, scaledCanvasData);
		}
	}
	
	private function drawEntity (_entity:Entity, _bitmapData:BitmapData) :Void {
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
		_bitmapData.draw(_entity.bitmapData, _matrix, _transform, _blendMode, _mask);
		// Draw entity's children
		for (_e in _entity.children) {
			drawEntity(_e, _bitmapData);
		}
	}
	
	private function clickHandler (_event:MouseEvent) :Void {
		// Search targets
		var _point:Point = new Point(Std.int(_event.stageX / SCALE), Std.int(_event.stageY / SCALE));
		var _targets:Array<Entity> = getEntitiesAt(scene, Std.int(_point.x), Std.int(_point.y));
		_targets = _targets.concat(getEntitiesAt(TextLayer.instance, Std.int(_point.x * SCALE), Std.int(_point.y * SCALE)));
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
			_targets.push(_entity);
		}
		for (_e in _entity.children) {
			_targets = _targets.concat(getEntitiesAt(_e, _x, _y));
		}
		return _targets;
	}
	
}

enum GameScene {
	startMenu;
	levelSelect;
	play;
	ending;
}









