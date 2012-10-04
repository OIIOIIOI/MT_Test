package com.m.utils;

class ColorManager
{
	
	static public function getRGBFromHex (_hex:UInt) :Dynamic {
		var _r:UInt = _hex >> 16 & 0xFF;
		var _g:UInt = _hex >>  8 & 0xFF;
		var _b:UInt = _hex & 0xFF;
		return { r:_r, g:_g, b:_b };
	}
	
	static public function getHexFromRGB (_r:UInt, _g:UInt, _b:UInt) :UInt {
		return (_r << 16) + (_g << 8) + _b;
	}
	
	static public function getARGBFromHex (_hex:UInt) :Dynamic {
		var _a:UInt = _hex >> 24 & 0xFF;
		var _r:UInt = _hex >> 16 & 0xFF;
		var _g:UInt = _hex >>  8 & 0xFF;
		var _b:UInt = _hex & 0xFF;
		return { a:_a, r:_r, g:_g, b:_b };
	}
	
	static public function getHexFromARGB (_a:UInt, _r:UInt, _g:UInt, _b:UInt) :UInt {
		return (_a << 24) + (_r << 16) + (_g << 8) + _b;
	}
	
	static public function desaturateRGB (_r:UInt, _g:UInt, _b:UInt) :UInt
	{
		return Std.int((_r * 0.3) + (_g * 0.59) + (_b * 0.11));
	}
	
	static public function desaturateHex (_hex:UInt) :UInt {
		var _rgb:Dynamic = getRGBFromHex(_hex);
		var _grayscale:UInt = Std.int((_rgb.r * 0.3) + (_rgb.g * 0.59) + (_rgb.b * 0.11));
		return getHexFromRGB(_grayscale, _grayscale, _grayscale);
	}
	
	static public function getHexFromHSL (_h:Float, _s:Float, _l:Float) :UInt
	{
		var _r:UInt;
		var _g:UInt;
		var _b:UInt;
		if (_s == 0) {
			_r = _g = _b = Std.int(_l * 255);
		}
		else {
			var _q:Float;
			if(_l <= 0.5)	_q = _l * (1 + _s);
			else			_q = _l + _s - (_l * _s);
			var _p:Float = 2 * _l - _q;
			_h /= 360;
			_r = getColorValueFromPQH(_p, _q, _h + 1 / 3);
			_g = getColorValueFromPQH(_p, _q, _h);
			_b = getColorValueFromPQH(_p, _q, _h - 1 / 3);
		}
		return getHexFromRGB(_r, _g, _b);
	}
	
	public static function getColorValueFromPQH (_p:Float, _q:Float, _h:Float) :UInt
	{
		if(_h < 0)			_h += 1;
		else if (_h > 1)	_h -= 1;
		var _v:Float;
		if(6 * _h < 1)		_v = _p + (_q - _p) * _h * 6;
		else if(2 * _h < 1)	_v = _q;
		else if(3 * _h < 2)	_v = _p + (_q - _p) * (2 / 3 - _h) * 6;
		else				_v = _p;
		return Std.int(_v * 255);
	}
	
	
	
	
	
	
	
	
}
