package com.m.mttest.entities;
import com.m.mttest.fx.AdvancedFadeFX;
import com.m.utils.ColorManager;
import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class Emitter extends Entity
{
	
	public function new () {
		super();
	}
	
	public function spawnParticles (_type:ParticleType, _x:Float, _y:Float) :Void {
		var _array:Array<Particle> = switch (_type) {
			case ParticleType.straw:	getStrawExplosion();
			case ParticleType.wool:		getWoolExplosion();
			case ParticleType.rock:		getRockExplosion();
			case ParticleType.bomb:		getBombExplosion();
		}
		for (_p in _array) {
			_p.x += _x;
			_p.y += _y;
			addChild(_p);
		}
	}
	
	public function clean () :Void {
		while (numChildren > 0) {
			getChildAt(0).destroy();
			removeChildAt(0);
		}
	}
	
	private function getBombExplosion () :Array<Particle> {
		var _array:Array<Particle> = new Array<Particle>();
		var _p:Particle;
		var _r:Int;
		for (_i in 0...8) {
			_r = Std.random(63) + 192;
			_p = new Particle(ColorManager.getHexFromARGB(255, _r, _r, 0), Std.random(2) + 1, Std.random(2) + 1);
			_p.addFX(new AdvancedFadeFX(_p.life, [new ColorTransform(), new ColorTransform(0, 0, 0)]));
			_array.push(_p);
			_r = Std.random(63) + 192;
			_p = new Particle(ColorManager.getHexFromARGB(255, _r, Std.int(_r / 2), 0), Std.random(2) + 1, Std.random(2) + 1);
			_p.addFX(new AdvancedFadeFX(_p.life, [new ColorTransform(), new ColorTransform(0, 0, 0)]));
			_array.push(_p);
		}
		return _array;
	}
	
	private function getStrawExplosion () :Array<Particle> {
		var _array:Array<Particle> = new Array<Particle>();
		var _p:Particle;
		var _color:UInt;
		for (_i in 0...16) {
			_color = 0xFF000000 + ColorManager.getHexFromHSL(65, 0.8, Math.random() * 0.3 + 0.7);
			_p = new Particle(_color, 2, 1);
			_p.addFX(new AdvancedFadeFX(_p.life, [new ColorTransform(), new ColorTransform(1, 1, 1, 0)]));
			_array.push(_p);
		}
		return _array;
	}
	
	private function getWoolExplosion () :Array<Particle> {
		var _array:Array<Particle> = new Array<Particle>();
		var _p:Particle;
		var _color:UInt;
		for (_i in 0...24) {
			_color = 0xFF000000 + ColorManager.getHexFromHSL(208, 0.25, Math.random() * 0.25 + 0.75);
			_p = new Particle(_color, 2, 2);
			_p.addFX(new AdvancedFadeFX(_p.life, [new ColorTransform(), new ColorTransform(1, 1, 1, 0)]));
			_array.push(_p);
		}
		return _array;
	}
	
	private function getRockExplosion () :Array<Particle> {
		var _array:Array<Particle> = new Array<Particle>();
		var _p:Particle;
		var _color:UInt;
		for (_i in 0...10) {
			_color = 0xFF000000 + ColorManager.getHexFromHSL(230, 0.25, Math.random() * 0.25 + 0.75);
			_p = new Particle(_color, 1, 1);
			_p.addFX(new AdvancedFadeFX(_p.life, [new ColorTransform(), new ColorTransform(1, 1, 1, 0)]));
			_array.push(_p);
		}
		return _array;
	}
	
}

class Particle extends Entity
{
	
	public var speedX:Float;
	public var speedY:Float;
	public var maxLife:Int;
	public var life:Int;
	
	public function new (_color:UInt, _width:Int = 1, _height:Int = 1) {
		super();
		width = _width;
		height = _height;
		color = _color;
		
		speedX = Math.random() * 1 - 0.5;
		speedY = Math.random() * 1 - 0.5;
		maxLife = life = 40;
	}
	
	override public function update () :Void {
		super.update();
		x += speedX;
		y += speedY;
		life--;
		if (life <= 0)
			dead = true;
	}
	
}

enum ParticleType {
	straw;
	wool;
	rock;
	bomb;
}
