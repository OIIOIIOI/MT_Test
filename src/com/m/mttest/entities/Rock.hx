package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Emitter;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.levels.Level;

/**
 * ...
 * @author 01101101
 */

class Rock extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	static public var FRAGILE:String = "fragile";
	static public var DEAD:String = "dead";
	
	public var state (default, null):RockState;
	private var health:Int;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level) {
		super(_x, _y, _level, LEType.rock);
		
		state = normal;
		health = 2;
		
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("rock0"));
		anims.push(_anim);
		_anim = new Animation(FRAGILE, "tiles");
		_anim.addFrame(new AnimFrame("rock1"));
		anims.push(_anim);
		_anim = new Animation(DEAD, "tiles");
		_anim.addFrame(new AnimFrame("rock2"));
		anims.push(_anim);
		
		play(IDLE);
	}
	
	override public function blowUp (_power:Int = 1) :Void {
		health = Std.int(Math.max(health - _power, 0));
		switch (health) {
			case 1:
				state = fragile;
				play(FRAGILE);
			case 0:
				state = gone;
				play(DEAD);
		}
		level.emitter.spawnParticles(ParticleType.rock, x + width / 2, y + height / 2);
		super.blowUp(_power);
	}
	
}

enum RockState {
	normal;
	fragile;
	gone;
}
