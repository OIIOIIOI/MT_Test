package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Emitter;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.Game;
import com.m.mttest.levels.Level;
import flash.geom.Rectangle;
import haxe.Timer;
import statm.explore.haxeAStar.AStar;
import statm.explore.haxeAStar.IntPoint;

/**
 * ...
 * @author 01101101
 */

class Sheep extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	static public var JUMP:String = "jump";
	static public var MOVING:String = "moving";
	static public var FALL:String = "fall";
	static public var DEAD:String = "dead";
	
	public var state (default, null):SheepState;
	private var path:Array<IntPoint>;
	private var pathIndex:Int;
	private var speed:Float;
	private var wait:Bool;
	private var sleepFX:SleepFX;
	
	// Exception for level_big_time
	private var badPathA:Array<IntPoint>;
	private var goodPathA:Array<IntPoint>;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level) {
		super(_x, _y, _level, LEType.sheep);
		
		state = asleep;
		pathIndex = 0;
		speed = 0.8;
		wait = true;
		
		hitBox = new Rectangle(6, 6, 4, 4);
		//drawHitBox = true;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("sheep_asleep"));
		anims.push(_anim);
		_anim = new Animation(MOVING, "tiles");
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.addFrame(new AnimFrame("sheep1"));
		_anim.fps = 8;
		anims.push(_anim);
		_anim = new Animation(JUMP, "tiles");
		_anim.addFrame(new AnimFrame("sheep_jump"));
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.fps = 10;
		anims.push(_anim);
		_anim = new Animation(FALL, "tiles");
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall1"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall1"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall0"));
		_anim.addFrame(new AnimFrame("sheep_fall2"));
		_anim.addFrame(new AnimFrame("sheep_fall3"));
		_anim.looping = false;
		_anim.fps = 10;
		anims.push(_anim);
		_anim = new Animation(DEAD, "tiles");
		_anim.addFrame(new AnimFrame("sheep_cry0"));
		_anim.addFrame(new AnimFrame("sheep_cry1"));
		_anim.addFrame(new AnimFrame("sheep_cry2"));
		_anim.addFrame(new AnimFrame("sheep_cry3"));
		_anim.addFrame(new AnimFrame("sheep_cry4"));
		_anim.fps = 18;
		anims.push(_anim);
		
		play(IDLE);
		
		sleepFX = new SleepFX();
		sleepFX.x = 1;
		sleepFX.y = -8;
		addChild(sleepFX);
	}
	
	override public function update () :Void {
		super.update();
		if (!active)
			return;
		// Search for a path
		if (path == null) {
			path = findPath();
			if (path != null) {
				if (Game.LEVELS[Game.CURRENT_LEVEL].name == "level_big_time") {
					if (badPathA == null) {
						badPathA = new Array<IntPoint>();
						badPathA.push(new IntPoint(1, 6));
						badPathA.push(new IntPoint(2, 6));
						badPathA.push(new IntPoint(3, 6));
						badPathA.push(new IntPoint(4, 6));
						badPathA.push(new IntPoint(4, 5));
						badPathA.push(new IntPoint(4, 4));
						badPathA.push(new IntPoint(4, 3));
						badPathA.push(new IntPoint(4, 2));
						badPathA.push(new IntPoint(5, 2));
						badPathA.push(new IntPoint(6, 2));
						//
						goodPathA = new Array<IntPoint>();
						goodPathA.push(new IntPoint(1, 6));
						goodPathA.push(new IntPoint(2, 6));
						goodPathA.push(new IntPoint(3, 6));
						goodPathA.push(new IntPoint(4, 6));
						goodPathA.push(new IntPoint(4, 5));
						goodPathA.push(new IntPoint(4, 4));
						goodPathA.push(new IntPoint(5, 4));
						goodPathA.push(new IntPoint(6, 4));
						goodPathA.push(new IntPoint(6, 3));
						goodPathA.push(new IntPoint(6, 2));
					}
					if (comparePaths(path, badPathA))
						path = goodPathA;
				}
				// FX
				removeChild(sleepFX);
				state = SheepState.moving;
				// Anim
				play(JUMP);
				Timer.delay(function () { if (active) { wait = false; play(MOVING); } }, 600);
			}
		}
		// If a path was found, move on
		if (!wait && path != null && pathIndex + 1 < path.length) {
			var _dX:Int = path[pathIndex + 1].x * Game.TILE_SIZE;
			var _dY:Int = path[pathIndex + 1].y * Game.TILE_SIZE;
			var _xDone:Bool = false;
			var _yDone:Bool = false;
			// X
			if (_dX > x) {
				x += speed;
				if (x >= _dX)	_xDone = true;
			}
			else if (_dX < x) {
				x -= speed;
				if (x <= _dX)	_xDone = true;
			}
			// Y
			if (_dY > y) {
				y += speed;
				if (y >= _dY)	_yDone = true;
			}
			else if (_dY < y) {
				y -= speed;
				if (y <= _dY)	_yDone = true;
			}
			// Check and adjust positions
			if (_xDone) {
				pathIndex++;
				if (pathIndex + 1 == path.length || _dX == path[pathIndex + 1].x * Game.TILE_SIZE)
					x = _dX;
			}
			else if (_yDone) {
				pathIndex++;
				if (pathIndex + 1 == path.length || _dY == path[pathIndex + 1].y * Game.TILE_SIZE)
					y = _dY;
			}
			mapX = Math.floor(x / Game.TILE_SIZE);
			mapY = Math.floor(y / Game.TILE_SIZE);
			// Check arrival
			if (x == path[path.length - 1].x * Game.TILE_SIZE && y == path[path.length - 1].y * Game.TILE_SIZE) {
				active = false;
				state = SheepState.arrived;
				EventManager.instance.dispatchEvent(new GameEvent(GameEvent.SHEEP_ARRIVED));
			}
		}
	}
	
	private function comparePaths (_pathA:Array<IntPoint>, _pathB:Array<IntPoint>) :Bool {
		if (_pathA.length != _pathB.length)	return false;
		for (_i in 0..._pathA.length) {
			if (!_pathA[_i].equals(_pathB[_i]))	return false;
		}
		return true;
	}
	
	public function findPath () :Array<IntPoint> {
		return AStar.getAStarInstance(level).findPath(new IntPoint(mapX, mapY), level.exitPos);
	}
	
	override public function blowUp (_power:Int = 1) :Void {
		if (state != SheepState.dead) {
			//trace("blowUp");
			removeChild(sleepFX);
			state = SheepState.dead;
			active = false;
			play(DEAD);
			level.emitter.spawnParticles(ParticleType.wool, x + width / 2, y + height / 2);
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.SHEEP_DIED));
		}
		super.blowUp(_power);
	}
	
	public function fall () :Void {
		if (state != SheepState.fallen) {
			state = SheepState.fallen;
			active = false;
			play(FALL);
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.SHEEP_DIED));
		}
	}
	
}

enum SheepState {
	asleep;
	moving;
	arrived;
	fallen;
	dead;
}










