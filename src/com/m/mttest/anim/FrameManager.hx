package com.m.mttest.anim;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.Json;

/**
 * ...
 * @author 01101101
 */

class FrameManager
{
	
	static private var pairs:Hash<FramePair>;
	
	static public function store (_id:String, _sheet:BitmapData, _jsonString:String) :Void {
		var _data:Dynamic = Json.parse(_jsonString);
		var _frames:Array<Frame> = new Array<Frame>();
		var _array:Array<Dynamic> = cast(_data.frames, Array<Dynamic>);
		if (_array.length <= 0)	return;
		var _frame:Frame;
		for (_f in _array) {
			_frame = new Frame();
			_frame.fromObject(_f);
			_frame.spritesheet = _sheet;
			_frames.push(_frame);
		}
		
		var _pair:FramePair = { sheet:_sheet, frames:_frames };
		if (pairs == null) {
			pairs = new Hash<FramePair>();
		}
		pairs.set(_id, _pair);
	}
	
	static public function getFrameInfo (_name:String, ?_id:String) :Frame {
		if (_id != null) {
			// If specified ID doesn't exist
			if (!pairs.exists(_id)) {
				return null;
			} else {
				// Look all frames for the specified name
				for (_f in pairs.get(_id).frames) {
					if (_f.name == _name) {
						return _f;
					}
				}
			}
		}
		// If not found or _id not specified
		for (_p in pairs) {
			for (_f in _p.frames) {
				if (_f.name == _name) {
					return _f;
				}
			}
		}
		return null;
	}
	
	static public function getFrame (_name:String, ?_id:String, ?_flipped:Bool = false) :BitmapData {
		var _data:BitmapData = null;
		if (_id != null) {
			// If specified ID doesn't exist
			if (!pairs.exists(_id)) {
				return null;
			} else {
				// Look all frames for the specified name
				for (_f in pairs.get(_id).frames) {
					if (_f.name == _name) {
						_data = new BitmapData(_f.width, _f.height, true, 0x00FF00FF);
						_data.copyPixels(pairs.get(_id).sheet, new Rectangle(_f.x, _f.y, _f.width, _f.height), new Point());
						//return _data;
					}
				}
			}
		}
		// If not found or _id not specified
		if (_data == null) {
			for (_p in pairs) {
				for (_f in _p.frames) {
					if (_f.name == _name) {
						_data = new BitmapData(_f.width, _f.height, true, 0x00FF00FF);
						_data.copyPixels(_p.sheet, new Rectangle(_f.x, _f.y, _f.width, _f.height), new Point());
					}
				}
			}
		}
		// Flip if needed and return data
		if (_data != null && _flipped) {
			var _tmp:BitmapData = _data.clone();
			var _matrix:Matrix = new Matrix();
			_matrix.scale(-1, 1);
			_matrix.translate(_tmp.width, 0);
			_data.fillRect(_data.rect, 0x00FF00FF);
			_data.draw(_tmp, _matrix);
			_tmp.dispose();
			_tmp = null;
		}
		return _data;
	}
	
}

typedef FramePair = {
	var sheet:BitmapData;
	var frames:Array<Frame>;
}