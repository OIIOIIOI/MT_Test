package com.m.mttest.levels;

import com.m.mttest.anim.FrameManager;
import com.m.mttest.entities.BasicBlock;
import com.m.mttest.entities.Blast;
import com.m.mttest.entities.Bomb;
import com.m.mttest.entities.Border;
import com.m.mttest.entities.Emitter;
import com.m.mttest.entities.Entity;
import com.m.mttest.entities.Hole;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.entities.Sheep;
import com.m.mttest.entities.Wall;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.Game;
import com.m.mttest.levels.Inventory;
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
	// Layers
	private var sceneLayer:Entity;
	private var itemsLayer:Entity;
	private var sheepLayer:Entity;
	private var collisionLayer:Entity;
	public var emitter (default, null):Emitter;
	// A* variables
	public var rowTotal (default, null):Int;
	public var colTotal (default, null):Int;
	public var allowDiag (default, null):Bool;
	public var exitPos (default, null):IntPoint;
	public var absoluteSearch:Bool;
	//
	private var blasts:Hash<String>;
	private var blownUpTiles:Array<BlowUpInfo>;
	public var endGameEntities (default, null):Array<LevelEntity>;
	public var active (default, null):Bool;
	
	public function new () {
		super();
		//
		allowDiag = false;
		absoluteSearch = false;
		// Entities
		sceneLayer = new Entity();
		itemsLayer = new Entity();
		sheepLayer = new Entity();
		collisionLayer = new Entity();
		emitter = new Emitter();
		//
		addChild(sceneLayer);
		addChild(itemsLayer);
		addChild(collisionLayer);
		addChild(sheepLayer);
		addChild(emitter);
		//
		blasts = new Hash<String>();
		blownUpTiles = new Array<BlowUpInfo>();
		endGameEntities = new Array<LevelEntity>();
		active = false;
	}
	
	public function load (_name:String) :Void {
		// Get level data
		levelData = FrameManager.getFrame(_name, "levels");
		if (levelData == null)
			throw new Error("The level \"" + _name + "\" was not found");
		levelData = addBorders(levelData);
		//
		userData = new BitmapData(levelData.width, levelData.height, false, 0xFFFFFFFF);
		// Parse data
		reset();
		// Init basic properties
		width = Std.int(levelData.width / 2) * Game.TILE_SIZE;
		height = Std.int(levelData.height / 2) * Game.TILE_SIZE;
		//color = 0xFFFFFFFF;
		// A* init and paths lookups
		colTotal = Std.int(levelData.width / 2);
		rowTotal = Std.int(levelData.height / 2);
		// Check if the map is playable
		if (!checkPaths())
			throw new Error("The level \"" + _name + "\" is not playable");
	}
	
	private function addBorders (_data:BitmapData) :BitmapData {
		var _returnData:BitmapData = new BitmapData(_data.width + 4, _data.height + 4, false, 0x660066);
		// Corners
		_returnData.setPixel(0, 1, 0x000007);
		_returnData.setPixel(_returnData.width - 2, 1, 0x000001);
		_returnData.setPixel(0, _returnData.height - 1, 0x000005);
		_returnData.setPixel(_returnData.width - 2, _returnData.height - 1, 0x000003);
		// Sides
		for (_y in 1...Std.int(_returnData.height / 2) - 1) {
			_returnData.setPixel(0, _y * 2 + 1, 0x000006);
			_returnData.setPixel(_returnData.width - 2, _y * 2 + 1, 0x000002);
		}
		// Bottom
		for (_x in 1...Std.int(_returnData.width / 2) - 1) {
			_returnData.setPixel(_x * 2, _returnData.height - 1, 0x000004);
		}
		// Level data
		_returnData.copyPixels(_data, _data.rect, new Point(2, 2));
		return _returnData;
	}
	
	private function checkPaths () :Bool {
		// Look for the exit tile
		if (exitPos == null) {
			trace("No exit tile was found");
			return false;
		}
		// Turn destructible tiles off
		absoluteSearch = true;
		updateMap();
		// Search for a path to the exit for each sheep
		for (_s in sheepLayer.children) {
			if (cast(_s, Sheep).findPath() == null) {
				trace("No available path to the exit was found for " + _s);
				return false;
			}
		}
		// Turn destructible tiles back on
		absoluteSearch = false;
		updateMap();
		return true;
	}
	
	public function reset (_full:Bool = false) :Void {
		// Deactivate
		active = false;
		// Remove entities
		emitter.clean();
		while (sceneLayer.numChildren > 0) {
			sceneLayer.getChildAt(0).destroy();
			sceneLayer.removeChildAt(0);
		}
		while (itemsLayer.numChildren > 0) {
			itemsLayer.getChildAt(0).destroy();
			itemsLayer.removeChildAt(0);
		}
		while (sheepLayer.numChildren > 0) {
			sheepLayer.getChildAt(0).destroy();
			sheepLayer.removeChildAt(0);
		}
		while (collisionLayer.numChildren > 0) {
			collisionLayer.getChildAt(0).destroy();
			collisionLayer.removeChildAt(0);
		}
		blasts = new Hash<String>();
		blownUpTiles = new Array<BlowUpInfo>();
		endGameEntities = new Array<LevelEntity>();
		// Parse data
		if (_full)	userData = new BitmapData(levelData.width, levelData.height, false, 0xFFFFFFFF);
		if (levelData != null)	parse(levelData);
		if (userData != null)	parse(userData);
		// Update map
		updateMap();
	}
	
	private function parse (_bitmapData:BitmapData) :Void {
		var _color:UInt;
		var _floorType:LEType;
		var _itemType:LEType;
		var _variant:Int;
		var _class:String;
		var _params:Array<Dynamic>;
		var _entity:LevelEntity;
		for (_y in 0...Std.int(_bitmapData.height / 2)) {
			for (_x in 0...Std.int(_bitmapData.width / 2)) {
				// Floor
				_color = _bitmapData.getPixel(_x * 2, _y * 2);
				_variant = _bitmapData.getPixel(_x * 2, _y * 2 + 1);
				if (_variant == Std.int(_color))	_variant = 0;
				_floorType = LevelEntity.colorToType(_color);
				//
				if (_floorType != null) {
					_class = LevelEntity.typeToClass(_floorType);
					_params = [_x, _y, this].concat(LevelEntity.getConstructorParams(_floorType, _variant));
					//trace("FLOOR create " + _class + " / " + _params);
					_entity = Type.createInstance(Type.resolveClass(_class), _params);
					addEntity(_entity);
				}
				// Item
				_color = _bitmapData.getPixel(_x * 2 + 1, _y * 2);
				_variant = _bitmapData.getPixel(_x * 2 + 1, _y * 2 + 1);
				if (_variant == Std.int(_color))	_variant = 0;
				_itemType = LevelEntity.colorToType(_color);
				//
				if (_itemType != null && _itemType != _floorType) {
					_class = LevelEntity.typeToClass(_itemType);
					_params = [_x, _y, this].concat(LevelEntity.getConstructorParams(_itemType, _variant));
					//trace("ITEM create " + _class + " / " + _params);
					_entity = Type.createInstance(Type.resolveClass(_class), _params);
					_entity.userPlaced = (_bitmapData == userData);
					addEntity(_entity);
				}
			}
		}
	}
	
	private function addEntity (_entity:LevelEntity) :Void {
		switch (_entity.type) {
			case LEType.sheep:
				sheepLayer.addChild(_entity);
				endGameEntities.push(_entity);
			case LEType.bomb:
				itemsLayer.addChild(_entity);
				endGameEntities.push(_entity);
				updateMap();
			case LEType.hole:
				collisionLayer.addChild(_entity);
				updateMap();
			case LEType.blast:
				collisionLayer.addChild(_entity);
			default:
				sceneLayer.addChild(_entity);
		}
		if (_entity.type == exit)
			exitPos = new IntPoint(_entity.mapX, _entity.mapY);
	}
	
	private function removeEntity (_entity:LevelEntity) :Void {
		switch (_entity.type) {
			case LEType.bomb:
				_entity.parent.removeChild(_entity);
				endGameEntities.remove(_entity);
				updateMap();
			case LEType.hole:
				_entity.parent.removeChild(_entity);
				updateMap();
			case LEType.sheep:
				_entity.parent.removeChild(_entity);
				endGameEntities.remove(_entity);
			default:
				_entity.parent.removeChild(_entity);
		}
		// Removing the exit will only be possible while editing levels
		if (_entity.type == exit)
			exitPos = null;
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
		for (_e in collisionLayer.children) {
			cast(_e, LevelEntity).activate();
		}
	}
	
	public function entityClickHandler (_target:LevelEntity) :Void {
		//trace("entityClickHandler: " + _target.type + " (user placed: " + _target.userPlaced + ")");
		if (active)	return;
		if (_target.userPlaced) {
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.REMOVE_ITEM, _target));
			return;
		}
		if (_target.type == LEType.floor) {
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.PLACE_ITEM, new IntPoint(_target.mapX, _target.mapY)));
			return;
		}
		EventManager.instance.dispatchEvent(new GameEvent(GameEvent.SET_HINT, LevelEntity.typeToDesc(_target.type)));
	}
	
	public function placeItem (_invObject:InvObject, _point:IntPoint) :Void {
		var _class:String = LevelEntity.typeToClass(_invObject.type);
		var _params:Array<Dynamic> = [_point.x, _point.y, this].concat(LevelEntity.getConstructorParams(_invObject.type, _invObject.variant));
		var _entity:LevelEntity = Type.createInstance(Type.resolveClass(_class), _params);
		_entity.userPlaced = true;
		addEntity(_entity);
		var _color:UInt = LevelEntity.typeToColor(_invObject.type);
		userData.setPixel(_entity.mapX * 2 + 1, _entity.mapY * 2, _color);
		_color = _invObject.variant;
		userData.setPixel(_entity.mapX * 2 + 1, _entity.mapY * 2 + 1, _color);
	}
	
	public function removeItem (_entity:LevelEntity) :Void {
		// Remove entity from scene
		removeEntity(_entity);
		// Update bitmap data
		var _bitmapData:BitmapData;
		if (_entity.userPlaced)	_bitmapData = userData;
		else					_bitmapData = levelData;
		// Get floor color and reset item pixels
		var _color:UInt = _bitmapData.getPixel(_entity.mapX * 2, _entity.mapY * 2);
		_bitmapData.setPixel(_entity.mapX * 2 + 1, _entity.mapY * 2, _color);
		_bitmapData.setPixel(_entity.mapX * 2 + 1, _entity.mapY * 2 + 1, _color);
	}
	
	private function getEntitiesAtPoint (_point:Point) :Array<LevelEntity> {
		//trace("getEntitiesAtPoint @ " + _point.x + ";" + _point.y);
		var _targets:Array<LevelEntity> = new Array<LevelEntity>();
		for (_e in sceneLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x, _point.y), false))
				_targets.push(cast(_e, LevelEntity));
		}
		for (_e in itemsLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x, _point.y), false))
				_targets.push(cast(_e, LevelEntity));
		}
		for (_e in sheepLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x, _point.y), false))
				_targets.push(cast(_e, LevelEntity));
		}
		for (_e in collisionLayer.children) {
			if (_e.hitTestPoint(new Point(_point.x, _point.y), false))
				_targets.push(cast(_e, LevelEntity));
		}
		return _targets;
	}
	
	public function updateMap () :Void {
		AStar.getAStarInstance(this).updateMap();
	}
	
	public function isWalkable (_x:Int, _y:Int) :Bool {
		//trace("isWalkable @ " + _x + ";" + _y);
		var _entities:Array<LevelEntity> = getEntitiesAtPoint(new Point(_x * Game.TILE_SIZE, _y * Game.TILE_SIZE));
		//trace("\t" + _entities);
		for (_e in _entities) {
			if (!_e.walkable)
				return false;
		}
		return true;
	}
	
	override public function update () :Void {
		//trace("--------------------------------------- update");
		// If tiles need to be blown up, BLOW THEM UP!
		var _temp:Array<BlowUpInfo> = blownUpTiles.splice(0, blownUpTiles.length);
		while (_temp.length > 0) {
			var _point:BlowUpInfo = _temp.shift();
			blowTileUp(_point);
		}
		// If blasts occured, add the entities
		if (Lambda.count(blasts) > 0) {
			addBlasts();
		}
		// Check for collisions
		var _sheep:Sheep;
		for (_s in sheepLayer.children) {
			_sheep = cast(_s, Sheep);
			if (_sheep.state != SheepState.dead && _sheep.state != SheepState.fallen) {
				for (_b in collisionLayer.children) {
					if (_sheep.hitTestRect(_b.absHitBox)) {
						if (Std.is(_b, Blast))
							_sheep.blowUp();
						else if (Std.is(_b, Hole)) {
							_sheep.x = _b.x;
							_sheep.y = _b.y;
							_sheep.fall();
						}
						break;
					}
				}
			}
		}
		// Update
		super.update();
	}
	
	private function blowTileUp (_point:BlowUpInfo) :Void {
		//trace("blowTileUp @ " + _point.x + ";" + _point.y);
		var _entities:Array<LevelEntity> = getEntitiesAtPoint(new Point(_point.x * Game.TILE_SIZE, _point.y * Game.TILE_SIZE));
		//trace("\t" + _entities);
		for (_e in _entities) {
			if (_e.destructible)	_e.blowUp(_point.p);
		}
	}
	
	public function blastBomb (_x:Int, _y:Int, _size:Int = 1) :Void {
		//trace("blast bomb @ " + _x + ";" + _y);
		var _tX:Int;
		var _tY:Int;
		var _indexOf:Int;
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
		if (_radius > 0) {
			_indexOf = isInBlownUpList(_x, _tY);
			if (_indexOf == -1)	blownUpTiles.push( { x:_x, y:_tY, p:1 } );
			else				blownUpTiles[_indexOf].p++;
		}
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
		if (_radius > 0) {
			_indexOf = isInBlownUpList(_x, _tY);
			if (_indexOf == -1)	blownUpTiles.push( { x:_x, y:_tY, p:1 } );
			else				blownUpTiles[_indexOf].p++;
		}
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
		if (_radius > 0) {
			_indexOf = isInBlownUpList(_tX, _y);
			if (_indexOf == -1)	blownUpTiles.push( { x:_tX, y:_y, p:1 } );
			else				blownUpTiles[_indexOf].p++;
		}
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
		if (_radius > 0) {
			_indexOf = isInBlownUpList(_tX, _y);
			if (_indexOf == -1)	blownUpTiles.push( { x:_tX, y:_y, p:1 } );
			else				blownUpTiles[_indexOf].p++;
		}
	}
	
	private function isInBlownUpList (_x:Int, _y:Int) :Int {
		for (_i in 0...blownUpTiles.length) {
			if (blownUpTiles[_i].x == _x && blownUpTiles[_i].y == _y)
				return _i;
		}
		return -1;
	}
	
	private function stopsBlast (_x:Int, _y:Int) :Bool {
		//trace("stopsBlast @ " + _x + ";" + _y);
		var _entities:Array<LevelEntity> = getEntitiesAtPoint(new Point(_x * Game.TILE_SIZE, _y * Game.TILE_SIZE));
		//trace("\t" + _entities);
		if (_entities.length == 0)	return true;
		for (_e in _entities) {
			if (_e.stopsBlast())	return true;
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

typedef BlowUpInfo = { x:Int, y:Int, p:Int }








