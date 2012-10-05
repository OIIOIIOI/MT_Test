package com.m.mttest.entities;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.anim.Frame;
import com.m.mttest.anim.FrameManager;
import com.m.mttest.fx.FX;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

using Lambda;
class Entity
{
	
	public var x (getX, setX):Float;
	public var y (getY, setY):Float;
	public var width (getWidth, setWidth):Int;
	public var height (getHeight, setHeight):Int;
	public var rect (getRect, never):Rectangle;
	public var absRect (getAbsRect, never):Rectangle;
	public var color:UInt;
	public var scaleX:Int;
	public var scaleY:Int;
	public var scale (getScale, setScale):Int;
	
	public var dead:Bool;
	
	public var parent (default, null) :Entity;
	public var children (default, null) :Array<Entity>;
	public var numChildren (getNumChildren, never) :Int;
	//public var depth (getDepth, never):Int;
	public var absX (getAbsX, never):Float;
	public var absY (getAbsY, never):Float;
	
	public var anims (default, null):Array<Animation>;
	public var currentAnim (default, null):Int;
	public var currentAnimName (getCurrentAnimName, never):String;
	public var currentFrameName (getCurrentFrameName, never):String;
	public var currentFrame (default, null):Int;
	public var paused:Bool;
	private var lastDraw:Float;
	public var bitmapData (getBitmapData, null):BitmapData;
	public var frameOffset (getFrameOffset, null):Point;
	
	public var effects (default, null):Array<FX>;
	public var alpha:Float;
	public var blendMode:BlendMode;
	public var mask:Rectangle = null;
	
	public function new () {
		dead = false;
		
		x = y = 0;
		scaleX = scaleY = 1;
		effects = new Array<FX>();
		alpha = 1;
		blendMode = BlendMode.NORMAL;
		
		parent = null;
		children = new Array<Entity>();
		
		resetAnims();
		
		width = 1;
		height = 1;
		color = 0;
		frameOffset = new Point();
		
		lastDraw = Date.now().getTime();
	}
	
	public function addChild (_entity:Entity) :Void {
		if (_entity.parent != null) {
			_entity.parent.removeChild(_entity);
		}
		children.push(_entity);
		_entity.parent = this;
	}
	
	public function removeChild (_entity:Entity) :Void {
		while (children.remove(_entity)) { };
		_entity.parent = null;
	}
	
	private function getNumChildren () :Int {
		return children.length;
	}
	
	public function getChildIndex (_child:Entity) :Int {
		for (_i in 0...numChildren) {
			if (children[_i] == _child)
				return _i;
		}
		return -1;
	}
	
	public function clickHandler () :Void {
		trace("clicked " + this);
	}
	
	private function getX () :Float {
		return x;
	}
	private function setX (_x:Float) :Float {
		x = _x;
		return x;
	}
	
	private function getY () :Float {
		return y;
	}
	private function setY (_y:Float) :Float {
		y = _y;
		return y;
	}
	
	private function getWidth () :Int {
		return width;
	}
	private function setWidth (_width:Int) :Int {
		width = _width;
		return width;
	}
	
	private function getHeight () :Int {
		return height;
	}
	private function setHeight (_height:Int) :Int {
		height = _height;
		return height;
	}
	
	private function getAbsX () :Float {
		var _v:Float = x;
		var _e:Entity = this;
		while (_e.parent != null) {
			_v += _e.parent.x;
			_e = _e.parent;
		}
		return _v;
	}
	private function getAbsY () :Float {
		var _v:Float = y;
		var _e:Entity = this;
		while (_e.parent != null) {
			_v += _e.parent.y;
			_e = _e.parent;
		}
		return _v;
	}
	
	public function getRect () :Rectangle {
		return new Rectangle(x, y, width, height);
	}
	
	public function getAbsRect () :Rectangle {
		return new Rectangle(absX, absY, width, height);
	}
	
	public function hitTestPoint (_point:Point, _abs:Bool = true) :Bool {
		if (_abs)	return (_point.x >= absX && _point.x < absX + width && _point.y >= absY && _point.y < absY + height);
		else		return (_point.x >= x && _point.x < x + width && _point.y >= y && _point.y < y + height);
	}
	
	public function hitTestRect (_rect:Rectangle, _abs:Bool = true) :Bool {
		if (_abs)	return (absRect.intersects(_rect));
		else		return (rect.intersects(_rect));
	}
	
	public function addFX (_fx:FX, _overwrite:Bool = true) :Void {
		for (f in effects) {
			if (Std.is(f, Type.getClass(_fx))) {
				if (!_overwrite)
					return;
				effects.remove(f);
			}
		}
		effects.push(_fx);
	}
	
	public function removeFX (?_fx:FX) :Void {
		if (_fx == null)	effects = new Array<FX>();
		else				effects.remove(_fx);
	}
	
	public function resetAnims () :Void {
		anims = new Array<Animation>();
		currentAnim = -1;
		currentFrame = -1;
		paused = true;
	}
	
	public function play (_animName:String) :Void {
		if (anims.length == 0)	return;
		
		for (i in 0...anims.length) {
			if (anims[i].name == _animName) {
				currentAnim = i;
				currentFrame = 0;
				lastDraw = Date.now().getTime();
				if (anims[i].frames.length == 1) {
					paused = true;
				} else {
					paused = false;
				}
				// Init width/height
				var _frame:Frame = FrameManager.getFrameInfo(currentFrameName, anims[i].spritesheet);
				if (_frame != null) {
					width = _frame.width;
					height = _frame.height;
				}
				break;
			}
		}
	}
	
	public function update () :Void {
		// Animate
		if (currentAnim != -1 &&
			anims[currentAnim].frames.length > 1 &&
			!paused &&
			Date.now().getTime() - lastDraw > 1000 / anims[currentAnim].fps)
		{
			currentFrame++;
			if (currentFrame >= anims[currentAnim].frames.length) {
				if (anims[currentAnim].looping)	currentFrame = 0;
				else							currentFrame = anims[currentAnim].frames.length - 1;
			}
			lastDraw = Date.now().getTime();
		}
		// Update FX
		for (_fx in effects) {
			if (_fx.complete)	removeFX(_fx);
			else				_fx.update();
		}
		// Update children
		children = children.filter(isAlive).array();
		for (_e in children) {
			_e.update();
		}
	}
	
	private function isAlive (_entity:Entity) :Bool {
		return !_entity.dead;
	}
	
	public function destroy () :Void {
		effects = null;
		if (bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}
	}
	
	private function getFrameData () :BitmapData {
		var _data:BitmapData = null;
		if (anims != null && currentAnim != -1) {
			var _animFrame:AnimFrame = anims[currentAnim].frames[currentFrame];
			_data = FrameManager.getFrame(_animFrame.name, anims[currentAnim].spritesheet, _animFrame.flipped);
		}
		return _data;
	}
	
	private function getBitmapData () :BitmapData {
		if (bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}
		bitmapData = getFrameData();
		if (bitmapData == null) {
			if (width < 1)	width = 10;
			if (height < 1)	height = 10;
			bitmapData = new BitmapData(width, height, true, color);
		}
		else {
			width = bitmapData.width;
			height = bitmapData.height;
		}
		return bitmapData;
	}
	
	private function getFrameOffset () :Point {
		if (anims != null && currentAnim != -1) {
			return new Point(anims[currentAnim].frames[currentFrame].x, anims[currentAnim].frames[currentFrame].y);
		}
		else return new Point();
	}
	
	private function getScale () :Int {
		return Std.int((scaleX + scaleY) / 2);
	}
	private function setScale (_scale:Int) :Int {
		scaleX = _scale;
		scaleY = _scale;
		return _scale;
	}
	
	private function getCurrentAnimName () :String {
		if (anims == null || anims[currentAnim] == null) return null;
		return anims[currentAnim].name;
	}
	
	private function getCurrentFrameName () :String {
		if (anims == null) return null;
		return anims[currentAnim].frames[currentFrame].name;
	}
	
}