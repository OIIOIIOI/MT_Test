package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.fx.AdvancedFadeFX;
import com.m.mttest.fx.ColorBlinkFX;
import com.m.mttest.fx.FadeFX;
import com.m.mttest.levels.Level;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

class Blast extends LevelEntity
{
	
	static public var BOTH:String = "both";
	static public var VERTICAL:String = "vertical";
	static public var HORIZONTAL:String = "horizontal";
	
	public function new (_x:Int = 0, _y:Int = 0, _level:Level, _animation:String) {
		super(_x, _y, _level, LEType.blast);
		
		hitBox = new Rectangle(2, 2, 12, 12);
		//drawHitBox = true;
		
		var _anim:Animation;
		_anim = new Animation(BOTH, "tiles");
		//_anim.addFrame(new AnimFrame("blast0"));
		_anim.addFrame(new AnimFrame("blast1"));
		//_anim.addFrame(new AnimFrame("blast2"));
		_anim.addFrame(new AnimFrame("blast3"));
		_anim.looping = false;
		_anim.fps = 24;
		anims.push(_anim);
		_anim = new Animation(VERTICAL, "tiles");
		//_anim.addFrame(new AnimFrame("vblast0"));
		_anim.addFrame(new AnimFrame("vblast1"));
		//_anim.addFrame(new AnimFrame("vblast2"));
		_anim.addFrame(new AnimFrame("vblast3"));
		_anim.looping = false;
		_anim.fps = 24;
		anims.push(_anim);
		_anim = new Animation(HORIZONTAL, "tiles");
		//_anim.addFrame(new AnimFrame("hblast0"));
		_anim.addFrame(new AnimFrame("hblast1"));
		//_anim.addFrame(new AnimFrame("hblast2"));
		_anim.addFrame(new AnimFrame("hblast3"));
		_anim.looping = false;
		_anim.fps = 24;
		anims.push(_anim);
		
		play(_animation);
	}
	
	override public function activate () :Void {
		super.activate();
		//alpha = 0.2;
		//effects.push(new ColorBlinkFX(1000, new ColorTransform(0, 0, 0), null, 12));
		//effects.push(new FadeFX(40, [1, 0], completeHandler));
		addFX(new AdvancedFadeFX(10, [new ColorTransform(), new ColorTransform(1, 1, 1, 0.1)], completeHandler, 40));
	}
	
	private function completeHandler () :Void {
		//alpha = 0;
		dead = true;
	}
	
}
