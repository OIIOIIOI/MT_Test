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
	
	public var x:Float;
	public var y:Float;
	public var width:Int;
	public var height:Int;
	public var rect (get_rect, never):Rectangle;
	public var absRect (get_absRect, never):Rectangle;
	public var color:UInt;
	public var scale (default, set_scale):Int;
	
	public var dead:Bool;
	
	public var parent (default, null) :Entity;
	public var children (default, null) :Array<Entity>;
	public var numChildren (get_numChildren, never) :Int;
	public var absX (get_absX, never):Float;
	public var absY (get_absY, never):Float;
	public var absScale (get_absScale, never):Int;
	
	public var mouseEnabled:Bool;
	public var customClickHandler:Entity->Void;
	
	public var anims (default, null):Array<Animation>;
	public var currentAnim (default, null):Int;
	public var currentAnimName (get_currentAnimName, never):String;
	public var currentFrameName (get_currentFrameName, never):String;
	public var currentFrame (default, null):Int;
	public var paused:Bool;
	private var lastDraw:Float;
	public var bitmapData (get_bitmapData, null):BitmapData;
	public var frameOffset (get_frameOffset, null):Point;
	public var hitBox:Rectangle;
	public var absHitBox (get_absHitBox, never):Rectangle;
	public var drawHitBox:Bool;
	
	public var effects (default, null):Array<FX>;
	public var alpha (default, set_alpha):Float;
	public var blendMode:BlendMode;
	public var mask:Rectangle = null;
	
	public function new () {
		dead = false;
		
		x = y = 0;
		scale = 1;
		effects = new Array<FX>();
		alpha = 1;
		blendMode = BlendMode.NORMAL;
		
		parent = null;
		children = new Array<Entity>();
		mouseEnabled = true;
		
		resetAnims();
		
		width = 1;
		height = 1;
		color = 0;
		frameOffset = new Point();
		
		lastDraw = Date.now().getTime();
		paused = false;
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
	
	public function removeChildAt (_index:Int) :Void {
		if (_index > numChildren - 1 || _index < -1)	return;
		removeChild(getChildAt(_index));
		//children.splice(_index, 1);
	}
	
	private function get_numChildren () :Int {
		if (children == null)	return 0;
		else					return children.length;
	}
	
	public function getChildIndex (_child:Entity) :Int {
		for (_i in 0...numChildren) {
			if (children[_i] == _child)
				return _i;
		}
		return -1;
	}
	
	public function getChildAt (_index:Int) :Entity {
		if (_index > numChildren - 1 || _index < -1)	return null;
		return children[_index];
	}
	
	public function clickHandler () :Void {
		if (customClickHandler != null)
			customClickHandler(this);
		//trace("clicked " + this);
	}
	
	private function get_absX () :Float {
		var _v:Float = x;
		var _e:Entity = this;
		while (_e.parent != null) {
			_v += _e.parent.x;
			_e = _e.parent;
		}
		return _v;
	}
	private function get_absY () :Float {
		var _v:Float = y;
		var _e:Entity = this;
		while (_e.parent != null) {
			_v += _e.parent.y;
			_e = _e.parent;
		}
		return _v;
	}
	
	private function get_absScale () :Int {
		var _v:Int = scale;
		var _e:Entity = this;
		while (_e.parent != null) {
			_v *= _e.parent.scale;
			_e = _e.parent;
		}
		return _v;
	}
	
	private function get_rect () :Rectangle {
		return new Rectangle(x, y, width, height);
	}
	
	private function get_absRect () :Rectangle {
		return new Rectangle(absX, absY, width, height);
	}
	
	private function get_absHitBox () :Rectangle {
		var _rect:Rectangle = absRect.clone();
		if (hitBox != null) {
			_rect.x += hitBox.x;
			_rect.y += hitBox.y;
			_rect.width = hitBox.width;
			_rect.height = hitBox.height;
		}
		return _rect;
	}
	
	private function set_alpha (_alpha:Float) :Float {
		alpha = _alpha;
		// Children
		if (children != null) {
			for (_e in children) {
				_e.alpha = _alpha;
			}
		}
		return alpha;
	}
	
	// TODO use hitbox, just like hitTestRect
	public function hitTestPoint (_point:Point, _abs:Bool = true) :Bool {
		if (_abs)	return (_point.x >= absX && _point.x < absX + width && _point.y >= absY && _point.y < absY + height);
		else		return (_point.x >= x && _point.x < x + width && _point.y >= y && _point.y < y + height);
	}
	
	public function hitTestRect (_rect:Rectangle, _abs:Bool = true) :Bool {
		var _hitRect:Rectangle = (_abs) ? absRect.clone() : rect.clone();
		if (hitBox != null) {
			_hitRect.x += hitBox.x;
			_hitRect.y += hitBox.y;
			_hitRect.width = hitBox.width;
			_hitRect.height = hitBox.height;
		}
		return (_hitRect.intersects(_rect));
	}
	
	public function addFX (_fx:FX, _overwrite:Bool = true, _applyToChildren:Bool = false) :Void {
		for (f in effects) {
			if (Std.is(f, Type.getClass(_fx))) {
				if (!_overwrite)
					return;
				effects.remove(f);
			}
		}
		effects.push(_fx);
		// Children
		if (_applyToChildren) {
			for (_e in children) {
				_e.addFX(_fx, _overwrite, _applyToChildren);
			}
		}
	}
	
	public function removeFX (?_fx:FX, _applyToChildren:Bool = false) :Void {
		if (_fx == null)	effects = new Array<FX>();
		else				effects.remove(_fx);
		// Children
		if (_applyToChildren) {
			for (_e in children) {
				_e.removeFX(_fx, _applyToChildren);
			}
		}
	}
	
	public function resetAnims () :Void {
		anims = new Array<Animation>();
		currentAnim = -1;
		currentFrame = -1;
		//paused = true;
	}
	
	public function play (_animName:String) :Void {
		if (anims.length == 0)	return;
		
		for (i in 0...anims.length) {
			if (anims[i].name == _animName) {
				currentAnim = i;
				currentFrame = 0;
				lastDraw = Date.now().getTime();
				/*if (anims[i].frames.length == 1) {
					paused = true;
				} else {
					paused = false;
				}*/
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
		if (paused)	return;
		// Animate
		if (currentAnim != -1 &&
			anims[currentAnim].frames.length > 1 &&
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
		var _e:Entity;
		while (numChildren > 0) {
			_e = getChildAt(0);
			removeChild(_e);
			_e.destroy();
			_e = null;
		}
	}
	
	private function get_frameData () :BitmapData {
		var _data:BitmapData = null;
		if (anims != null && currentAnim != -1) {
			var _animFrame:AnimFrame = anims[currentAnim].frames[currentFrame];
			_data = FrameManager.getFrame(_animFrame.name, anims[currentAnim].spritesheet, _animFrame.flipped);
		}
		return _data;
	}
	
	private function get_bitmapData () :BitmapData {
		if (bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}
		bitmapData = get_frameData();
		if (bitmapData == null) {
			if (width < 1)	width = 10;
			if (height < 1)	height = 10;
			bitmapData = new BitmapData(width, height, true, color);
		}
		else {
			width = bitmapData.width;
			height = bitmapData.height;
		}
		if (drawHitBox) {
			var _hitData:BitmapData;
			var _point:Point = new Point();
			if (hitBox != null) {
				_hitData = new BitmapData(Std.int(hitBox.width), Std.int(hitBox.height), true, 0x80FF00FF);
				_point.x = hitBox.x;
				_point.y = hitBox.y;
			}
			else _hitData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x80FF00FF);
			bitmapData.copyPixels(_hitData, _hitData.rect, _point, null, null, true);
			_hitData.dispose();
			_hitData = null;
		}
		return bitmapData;
	}
	
	private function get_frameOffset () :Point {
		if (anims != null && currentAnim != -1) {
			return new Point(anims[currentAnim].frames[currentFrame].x, anims[currentAnim].frames[currentFrame].y);
		}
		else return new Point();
	}
	
	private function set_scale (_scale:Int) :Int {
		scale = _scale;
		return scale;
	}
	
	private function get_currentAnimName () :String {
		if (anims == null || anims[currentAnim] == null) return null;
		return anims[currentAnim].name;
	}
	
	private function get_currentFrameName () :String {
		if (anims == null) return null;
		return anims[currentAnim].frames[currentFrame].name;
	}
	
}