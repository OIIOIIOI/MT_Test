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

class Wall extends LevelEntity
{
	
	static public var IDLE:String = "idle";
	static public var DEAD:String = "dead";
	
	public var state (default, null):WallState;
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level) {
		super(_x, _y, _level, LEType.wall);
		
		state = normal;
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		_anim.addFrame(new AnimFrame("wall0"));
		anims.push(_anim);
		_anim = new Animation(DEAD, "tiles");
		_anim.addFrame(new AnimFrame("wall0_dead"));
		anims.push(_anim);
		play(IDLE);
	}
	
	override public function blowUp (_power:Int = 1) :Void {
		if (state == normal) {
			state = gone;
			play(DEAD);
			level.emitter.spawnParticles(ParticleType.straw, x + width / 2, y + height / 2);
		}
		super.blowUp(_power);
	}
	
}

enum WallState {
	normal;
	gone;
}





