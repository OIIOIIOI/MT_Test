package com.m.mttest.levels;

import com.m.mttest.anim.FrameManager;
import com.m.mttest.entities.Blast;
import com.m.mttest.entities.Bomb;
import com.m.mttest.entities.Entity;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.entities.Sheep;
import com.m.mttest.entities.Wall;
import com.m.mttest.Game;
import flash.display.BitmapData;
import flash.errors.Error;
import flash.geom.Point;
import statm.explore.haxeAStar.AStar;
import statm.explore.haxeAStar.IAStarClient;
import statm.explore.haxeAStar.IntPoint;

/**
 * ...
 * @author 01101101
 */

using Lambda;
class Level extends Entity, implements IAStarClient
{
	// Bitmap data
	private var levelData:BitmapData;
	private var userData:BitmapData;
	// Arrayed data
	private var data:Array<Array<Array<LevelEntity>>>;
	// Layers
	private var sceneLayer:Entity;
	private var itemsLayer:Entity;
	private var sheepLayer:Entity;
	private var blastsLayer:Entity;
	// A* variables
	public var rowTotal (default, null):Int;
	public var colTotal (default, null):Int;
	public var allowDiag (default, null):Bool;
	public var exitPos (default, null):IntPoint;
	public var absoluteSearch:Bool;
	//
	private var blasts:Hash<String>;
	private var blownUpTiles:Hash <Bool>;
	private var active:Bool;
	
	public function new () {
		super();
		//
		allowDiag = false;
		absoluteSearch = false;
		// Layers
		sceneLayer = new Entity();
		itemsLayer = new Entity();
		sheepLayer = new Entity();
		blastsLayer = new Entity();
		addChild(sceneLayer);
		addChild(itemsLayer);
		addChild(sheepLayer);
		addChild(blastsLayer);
		//
		blasts = new Hash<String>();
		blownUpTiles = new Hash<Bool>();
		active = false;
	}
	
	public function load (_name:String) :Void {
		// Get level data
		levelData = FrameManager.getFrame(_name, "levels");
		if (levelData == null)
			throw new Error("The level \"" + _name + "\" was found");
		//
		data = new Array<Array<Array<LevelEntity>>>();
		userData = new BitmapData(levelData.width, levelData.height, false, 0xFFFFFFFF);
		// Parse data
		reset();
		// Init basic properties
		width = Std.int(levelData.width / 2) * Game.TILE_SIZE;
		height = Std.int(levelData.height / 2) * Game.TILE_SIZE;
		color = 0xFFFFFFFF;
		// A* init and paths lookups
		colTotal = Std.int(levelData.width / 2);
		rowTotal = Std.int(levelData.height / 2);
		if (exitPos == null) {
			trace("No exit tile was found");
			return;
		}
		// Turn destructible tiles off
		absoluteSearch = true;
		updateMap();
		// Search for a path to the exit for each sheep
		for (_s in sheepLayer.children) {
			if (cast(_s, Sheep).findPath() == null) {
				trace("No available path to the exit was found for " + _s);
			}
		}
		// Turn destructible tiles back on
		absoluteSearch = false;
		updateMap();
	}
	
	private function reset () :Void {
		if (levelData != null)	parse(levelData);
		if (userData != null)	parse(userData);
	}
	
	private function parse (_bitmapData:BitmapData) :Void {
		var _color:UInt;
		var _floorType:LEType;
		var _itemType:LEType;
		var _class:String;
		var _params:Array<Dynamic>;
		var _entity:LevelEntity;
		for (_y in 0...Std.int(_bitmapData.height / 2)) {
			if (data[_y] == null)
				data.push(new Array<Array<LevelEntity>>());
			for (_x in 0...Std.int(_bitmapData.width / 2)) {
				if (data[_y][_x] == null)
					data[_y].push(new Array<LevelEntity>());
				// Background
				_color = _bitmapData.getPixel(_x * 2, _y * 2);
				_floorType = LevelEntity.colorToType(_color);
				if (_floorType != null) {
					_class = LevelEntity.typeToClass(_floorType);
					_params = [_x, _y, this].concat(LevelEntity.getConstructorParams(_floorType));
					_entity = Type.createInstance(Type.resolveClass(_class), _params);
					addEntity(_entity);
				}
				// Item
				_color = _bitmapData.getPixel(_x * 2 + 1, _y * 2);
				_itemType = LevelEntity.colorToType(_color);
				if (_itemType != null && _itemType != _floorType) {
					_class = LevelEntity.typeToClass(_itemType);
					_params = [_x, _y, this].concat(LevelEntity.getConstructorParams(_itemType));
					_entity = Type.createInstance(Type.resolveClass(_class), _params);
					addEntity(_entity);
				}
			}
		}
	}
	
	public function addEntity (_entity:LevelEntity) :Void {
		if (_entity.type == sheep)		sheepLayer.addChild(_entity);
		else if (_entity.type == bomb)	itemsLayer.addChild(_entity);
		else if (_entity.type == blast)	blastsLayer.addChild(_entity);
		else {
			sceneLayer.addChild(_entity);
			data[_entity.mapY][_entity.mapX].push(_entity);
		}
		if (_entity.type == exit)		exitPos = new IntPoint(_entity.mapX, _entity.mapY);
	}
	
	public function activate () :Void {
		active = true;
		for (_e in sceneLayer.children) {
			cast(_e, LevelEntity).activate();
		}
		for (_e in itemsLayer.children) {
			cast(_e, LevelEntity).activate();
		}
		for (_e in sheepLayer.children) {
			cast(_e, LevelEntity).activate();
		}
		for (_e in blastsLayer.children) {
			cast(_e, LevelEntity).activate();
		}
	}
	
	public function click (_point:Point) :Void {
		var _targets:Array<LevelEntity> = getEntitiesAtPoint(_point);
		if (_targets.length > 0) {
			var _target:LevelEntity = _targets.pop();
			//trace("upper entity clicked: " + _target.type);
			if (_target.type == LEType.floor)
				addEntity(new Bomb(_target.mapX, _target.mapY, this, 1));
		}
	}
	
	private function getEntitiesAtPoint (_point:Point) :Array<LevelEntity> {
		var _targets:Array<LevelEntity> = new Array<LevelEntity>();
		for (_e in sceneLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x - absX, _point.y - absY)))
				_targets.push(cast(_e, LevelEntity));
		}
		for (_e in itemsLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x - absX, _point.y - absY)))
				_targets.push(cast(_e, LevelEntity));
		}
		for (_e in sheepLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x - absX, _point.y - absY)))
				_targets.push(cast(_e, LevelEntity));
		}
		return _targets;
	}
	
	public function updateMap () :Void {
		AStar.getAStarInstance(this).updateMap();
	}
	
	public function isWalkable (_x:Int, _y:Int) :Bool {
		var _entities:Array<LevelEntity> = data[_y][_x];
		for (_e in _entities) {
			if (!_e.walkable)
				return false;
		}
		return true;
	}
	
	override public function update () :Void {
		// Update
		super.update();
		// If tiles need to be blown up, BLOW THEM UP!
		if (Lambda.count(blownUpTiles) > 0) {
			var _point:Array<String>;
			for (_k in blownUpTiles.keys()) {
				_point = _k.split(";");
				blowTileUp(Std.parseInt(_point[0]), Std.parseInt(_point[1]));
			}
			blownUpTiles = new Hash<Bool>();
		}
		// If blasts occured, add the entities
		if (Lambda.count(blasts) > 0)
			addBlasts();
		//trace(blastsLayer.numChildren);
		
		// Check for collisions
		var _sheep:Sheep;
		for (_s in sheepLayer.children) {
			_sheep = cast(_s, Sheep);
			if (_sheep.state == SheepState.alive) {
				for (_b in blastsLayer.children) {
					if (_sheep.hitTestRect(_b.absRect)) {
						_sheep.blowUp();
						break;
					}
				}
			}
		}
	}
	
	private function blowTileUp (_x:Int, _y:Int) :Void {
		//var _entities:Array<LevelEntity> = data[_y][_x];
		var _entities:Array<LevelEntity> = getEntitiesAtPoint(new Point(_x * Game.TILE_SIZE, _y * Game.TILE_SIZE));
		for (_e in _entities) {
			if (_e.destructible)
				_e.blowUp();
		}
	}
	
	public function blastBomb (_x:Int, _y:Int, _size:Int = 1) :Void {
		trace("blast bomb @ " + _x + ";" + _y);
		var _tX:Int;
		var _tY:Int;
		var _radius:Int;
		var _blastPath:Array<LevelEntity> = new Array<LevelEntity>();
		// Bomb position
		if (!stopsBlast(_x, _y))
			blasts.set(_x + ";" + _y, Blast.BOTH);
		// Blast down
		_radius = _size;
		_tY = _y + 1;
		while (_radius > 0 && !stopsBlast(_x, _tY)) {
			if (!blasts.exists(_x + ";" + _tY))
				blasts.set(_x + ";" + _tY, Blast.VERTICAL);
			else if (blasts.get(_x + ";" + _tY) == Blast.HORIZONTAL)
				blasts.set(_x + ";" + _tY, Blast.BOTH);
			_tY++;
			_radius--;
		}
		if (!blownUpTiles.exists(_x + ";" + _tY))
			blownUpTiles.set(_x + ";" + _tY, true);
		// Blast up
		_radius = _size;
		_tY = _y - 1;
		while (_radius > 0 && !stopsBlast(_x, _tY)) {
			if (!blasts.exists(_x + ";" + _tY))
				blasts.set(_x + ";" + _tY, Blast.VERTICAL);
			else if (blasts.get(_x + ";" + _tY) == Blast.HORIZONTAL)
				blasts.set(_x + ";" + _tY, Blast.BOTH);
			_tY--;
			_radius--;
		}
		if (!blownUpTiles.exists(_x + ";" + _tY))
			blownUpTiles.set(_x + ";" + _tY, true);
		// Blast right
		_radius = _size;
		_tX = _x + 1;
		while (_radius > 0 && !stopsBlast(_tX, _y)) {
			if (!blasts.exists(_tX + ";" + _y))
				blasts.set(_tX + ";" + _y, Blast.HORIZONTAL);
			else if (blasts.get(_tX + ";" + _y) == Blast.VERTICAL)
				blasts.set(_tX + ";" + _y, Blast.BOTH);
			_tX++;
			_radius--;
		}
		if (!blownUpTiles.exists(_tX + ";" + _y))
			blownUpTiles.set(_tX + ";" + _y, true);
		// Blast left
		_radius = _size;
		_tX = _x - 1;
		while (_radius > 0 && !stopsBlast(_tX, _y)) {
			if (!blasts.exists(_tX + ";" + _y))
				blasts.set(_tX + ";" + _y, Blast.HORIZONTAL);
			else if (blasts.get(_tX + ";" + _y) == Blast.VERTICAL)
				blasts.set(_tX + ";" + _y, Blast.BOTH);
			_tX--;
			_radius--;
		}
		if (!blownUpTiles.exists(_tX + ";" + _y))
			blownUpTiles.set(_tX + ";" + _y, true);
	}
	
	public function stopsBlast (_x:Int, _y:Int) :Bool {
		//var _entities:Array<LevelEntity> = data[_y][_x];
		var _entities:Array<LevelEntity> = getEntitiesAtPoint(new Point(_x * Game.TILE_SIZE, _y * Game.TILE_SIZE));
		for (_e in _entities) {
			if (_e.stopsBlast()) {
				trace(_x + ";" + _y + ": " + _e.type + " -> " + _e.stopsBlast());
				return true;
			}
		}
		return false;
	}
	
	private function addBlasts () :Void {
		var _point:Array<String>;
		var _entity:LevelEntity;
		for (_k in blasts.keys()) {
			_point = _k.split(";");
			_entity = new Blast(Std.parseInt(_point[0]), Std.parseInt(_point[1]), this, blasts.get(_k));
			addEntity(_entity);
			_entity.activate();
		}
		blasts = new Hash<String>();
	}
	
}










