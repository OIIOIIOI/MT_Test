package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.anim.Frame;
import com.m.mttest.anim.FrameManager;
import com.m.mttest.entities.Entity;
import flash.geom.Point;

/**
 * ...
 * @author 01101101
 */

class BitmapText extends Entity
{
	
	static public var PRE_LETTERS:String = "letter_";
	static public var PRE_NUMBERS:String = "number_";
	static public var PRE_SYMBOLS:String = "symbol_";
	
	static public var BANK:Hash<String>;
	static public var ASSOC:Hash<String>;
	static public var OFFSETS:Hash<Point>;
	static public var OFFSETS_NEXT:Hash<Point>;
	
	private var CHAR_SPACE:Int;
	private var WORD_SPACE:Int;
	
	public var text (default, setText):String;
	
	public var spritesheet (default, null):String;
	
	public function new (_text:String, ?_spritesheet:String = "font_volter") {
		super();
		
		if (BANK == null) {
			BANK = new Hash<String>();
			BANK.set(PRE_LETTERS, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
			BANK.set(PRE_NUMBERS, "0123456789");
			BANK.set(PRE_SYMBOLS, ".,:;?!'\"/\\*+-=_~%()[]{}#&<>²|@°éèêëàâùûüïôöç");
		}
		if (ASSOC == null) {
			ASSOC = new Hash<String>();
			// Accents
			ASSOC.set("é", "eacute");
			ASSOC.set("è", "egrave");
			ASSOC.set("ê", "ecirc");
			ASSOC.set("ë", "euml");
			ASSOC.set("à", "agrave");
			ASSOC.set("â", "acirc");
			ASSOC.set("ù", "ugrave");
			ASSOC.set("û", "ucirc");
			ASSOC.set("ü", "uuml");
			ASSOC.set("ï", "iuml");
			ASSOC.set("ô", "ocirc");
			ASSOC.set("ö", "ouml");
			ASSOC.set("ç", "ccedil");
			// Symbols
			ASSOC.set(".", "period");
			ASSOC.set(",", "comma");
			ASSOC.set(":", "colon");
			ASSOC.set(";", "scolon");
			ASSOC.set("?", "question");
			ASSOC.set("!", "exclam");
			ASSOC.set("'", "squote");
			ASSOC.set("\"", "dquote");
			ASSOC.set("/", "fslash");
			ASSOC.set("\\", "bslash");
			ASSOC.set("*", "star");
			ASSOC.set("+", "plus");
			ASSOC.set("-", "minus");
			ASSOC.set("=", "equal");
			ASSOC.set("_", "under");
			ASSOC.set("~", "tilde");
			ASSOC.set("%", "percent");
			ASSOC.set("(", "lparen");
			ASSOC.set(")", "rparen");
			ASSOC.set("[", "lbracket");
			ASSOC.set("]", "rbracket");
			ASSOC.set("{", "lbrace");
			ASSOC.set("}", "rbrace");
			ASSOC.set("#", "hash");
			ASSOC.set("&", "amp");
			ASSOC.set("<", "lt");
			ASSOC.set(">", "gt");
			ASSOC.set("²", "sup2");
			ASSOC.set("|", "pipe");
			ASSOC.set("@", "at");
			ASSOC.set("°", "deg");
		}
		
		setSpritesheet(_spritesheet, false);
		text = _text;
	}
	
	private function setText (_text:String) :String {
		text = _text;
		draw();
		return _text;
	}
	
	private function draw () :Void {
		if (text == null)	return;
		while (numChildren > 0) {
			removeChildAt(0);
		}
		
		var _pos:Int = 0;
		var _array:Array<String> = text.split("");
		var _prefix:String;
		var _entity:Entity;
		
		for (_c in _array) {
			if (_c == " ") {
				_pos += WORD_SPACE * scale;
				continue;
			}
			_prefix = findPrefix(_c);
			if (_prefix == null) {
				continue;
			}
			else if (_prefix == PRE_SYMBOLS) {
				_c = ASSOC.get(_c);
			}
			_entity = new Entity();
			setAnimations(_entity, _prefix + _c);
			_entity.mouseEnabled = false;
			_entity.play("idle");
			
			_entity.x = _pos;
			_entity.y = 0;
			var _frame:Frame = FrameManager.getFrameInfo(_prefix + _c, spritesheet);
			if (_frame == null)
				_frame = new Frame(_prefix + _c, _prefix + _c, 0, 0, 1, 1);
			var _frameOffset:Int = _entity.anims[_entity.currentAnim].frames[_entity.currentFrame].x;
			var _offsetNext:Point = new Point();
			if (OFFSETS_NEXT.exists(_prefix + _c))	_offsetNext = OFFSETS_NEXT.get(_prefix + _c);
			_pos += (_frame.width + CHAR_SPACE + _frameOffset + Std.int(_offsetNext.x)) * scale;
			width = _pos;
			if (_frame.height * scale > height)	height = _frame.height * scale;
			addChild(_entity);
		}
		width += scale;
	}
	
	private function findPrefix (_c:String) :String {
		for (key in BANK.keys()) {
			if (BANK.get(key).indexOf(_c) != -1) {
				return key;
			}
		}
		return null;
	}
	
	private function setAnimations (_entity:Entity, _frameName:String) :Void {
		var _anim:Animation = new Animation("idle", spritesheet);
		var _offset:Point = new Point();
		if (OFFSETS.exists(_frameName))	_offset = OFFSETS.get(_frameName);
		_anim.addFrame(new AnimFrame(_frameName, Std.int(_offset.x), Std.int(_offset.y)));
		_entity.anims.push(_anim);
	}
	
	override private function setScale (_scale:Int) :Int {
		scale = _scale;
		draw();
		return scale;
	}
	
	public function setSpritesheet (_spritesheet:String, _redraw:Bool = true) :Void {
		spritesheet = _spritesheet;
		switch (spritesheet) {
			case "font_superscript":
				CHAR_SPACE = 1;
				WORD_SPACE = 3;
				OFFSETS = new Hash<Point>();
				OFFSETS_NEXT = new Hash<Point>();
				var _s:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
				for (_l in _s.split("")) {
					OFFSETS_NEXT.set("letter_" + _l, new Point(-1));
				}
				for (_i in 0...10) {
					OFFSETS_NEXT.set("number_" + _i, new Point(-1));
				}
			case "font_m_mini":
				CHAR_SPACE = 1;
				WORD_SPACE = 2;
				OFFSETS = new Hash<Point>();
				OFFSETS_NEXT = new Hash<Point>();
			case "font_numbers_red", "font_numbers_blue", "font_numbers_gold":
				CHAR_SPACE = -1;
				WORD_SPACE = 3;
				OFFSETS = new Hash<Point>();
				OFFSETS_NEXT = new Hash<Point>();
			default:
				CHAR_SPACE = 1;
				WORD_SPACE = 3;
				OFFSETS = new Hash<Point>();
				OFFSETS_NEXT = new Hash<Point>();
		}
		if (_redraw)	draw();
	}
	
}










