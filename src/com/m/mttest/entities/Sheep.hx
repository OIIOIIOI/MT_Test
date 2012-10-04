package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.Game;
import com.m.mttest.levels.Level;
import statm.explore.haxeAStar.AStar;
import statm.explore.haxeAStar.IntPoint;

/**
 * ...
 * @author 01101101
 */

class Sheep extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	static public var DEAD:String = "dead";
	
	private var path:Array<IntPoint>;
	private var pathIndex:Int;
	private var speed:Float;
	public var state (default, null):SheepState;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level) {
		super(_x, _y, _level, LEType.sheep);
		
		pathIndex = 0;
		speed = 0.7;
		state = alive;
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("sheep0"));
		_anim.addFrame(new AnimFrame("sheep1"));
		_anim.fps = 8;
		anims.push(_anim);
		_anim = new Animation(DEAD, "tiles");
		//_anim.addFrame(new AnimFrame("sheep_naked0"));
		_anim.addFrame(new AnimFrame("sheep_cry0"));
		_anim.addFrame(new AnimFrame("sheep_cry1"));
		_anim.addFrame(new AnimFrame("sheep_cry2"));
		_anim.addFrame(new AnimFrame("sheep_cry3"));
		_anim.addFrame(new AnimFrame("sheep_cry4"));
		_anim.fps = 18;
		anims.push(_anim);
		play(IDLE);
	}
	
	override public function update () :Void {
		super.update();
		if (!active)	return;
		// Search for a path
		if (path == null)	path = findPath();
		// If a path was found, move on
		if (path != null && pathIndex + 1 < path.length) {
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
				if (pathIndex + 1 == path.length || _dX == path[pathIndex + 1].x * Game.TILE_SIZE) {
					x = _dX;
				}
			}
			else if (_yDone) {
				pathIndex++;
				if (pathIndex + 1 == path.length || _dY == path[pathIndex + 1].y * Game.TILE_SIZE) {
					y = _dY;
				}
			}
			mapX = Math.floor(x / Game.TILE_SIZE);
			mapY = Math.floor(y / Game.TILE_SIZE);
			
			/*if (pathIndex + 1 == path.length) {
				trace("done");
			}*/
		}
	}
	
	public function findPath () :Array<IntPoint> {
		return AStar.getAStarInstance(level).findPath(new IntPoint(mapX, mapY), level.exitPos);
	}
	
	override public function blowUp () :Void {
		if (state == SheepState.alive) {
			//trace("blowUp");
			state = SheepState.dead;
			active = false;
			play(DEAD);
			level.addChild(new Emitter(x + width / 2, y + height / 2, "wool"));
		}
		super.blowUp();
	}
	
}

enum SheepState {
	alive;
	dead;
}










