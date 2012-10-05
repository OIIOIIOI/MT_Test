package com.m.mttest;

import com.m.mttest.display.Interface;
import com.m.mttest.entities.BasicBlock;
import com.m.mttest.entities.Entity;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.entities.Selection;
import com.m.mttest.fx.AdvancedFadeFX;
import com.m.mttest.fx.ColorBlinkFX;
import com.m.mttest.fx.ColorFX;
import com.m.mttest.fx.FadeFX;
import com.m.mttest.fx.ShakeFX;
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
	inline static public var TILE_SIZE:UInt = 16;// The size of a single tile
	
	private var canvas:Bitmap;// The display container
	private var canvasData:BitmapData;// The display data
	
	private var entities:Array<Entity>;// A list of all the entities to update
	
	private var scene:Entity;
	private var level:Level;
	private var GUI:Interface;
	private var selection:Selection;
	
	private var lastFrame:Float;// The last time the game was updated
	
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
		
		level = new Level();
		level.load("level1");
		//level.load("sandbox0");
		level.x = (SIZE.width - level.width) / 2;
		level.y = (SIZE.height - level.height) / 2;
		scene.addChild(level);
		
		GUI = new Interface();
		scene.addChild(GUI);
		
		selection = new Selection();
		
		// Start main loop
		lastFrame = 0;
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		stage.addEventListener(MouseEvent.CLICK, clickHandler);
		KeyboardManager.setCallback(Keyboard.SPACE, activateLevel, null, true);
	}
	
	private function activateLevel () :Void {
		level.activate();
	}
	
	private function enterFrameHandler (_event:Event) :Void {
		// Check if it's time to update the game (a frame has passed)
		if (Date.now().getTime() - lastFrame >= 1 / FPS) {
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
		// Remove selection
		scene.removeChild(selection);
		// Search targets
		var _point:Point = new Point(Std.int(_event.stageX / SCALE), Std.int(_event.stageY / SCALE));
		var _targets:Array<Entity> = getEntitiesAt(entities[0], Std.int(_point.x), Std.int(_point.y));
		trace("click targets " + _targets);
		if (_targets.length > 0) {
			var _target:Entity = _targets.pop();
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
	
}










