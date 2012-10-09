package com.m.mttest.display;

import com.m.mttest.anim.Animation;
import com.m.mttest.anim.AnimFrame;
import com.m.mttest.entities.Entity;

/**
 * ...
 * @author 01101101
 */

class Button extends Entity
{
	
	static public var IDLE:String = "idle";
	
	private var type:ButtonType;
	public var icon (default, null):Entity;
	
	public function new (_size:Int, _type:ButtonType) {
		super();
		type = _type;
		// Background
		var _anim:Animation;
		_anim = new Animation(IDLE, "tiles");
		switch (_size) {
			default:	_anim.addFrame(new AnimFrame("empty_slot_18"));
			case 22:	_anim.addFrame(new AnimFrame("empty_slot_22"));
			case 24:	_anim.addFrame(new AnimFrame("empty_slot_24"));
			case 999:	_anim.addFrame(new AnimFrame("bg_menu_list"));
		}
		anims.push(_anim);
		play(IDLE);
		// Icon
		icon = switch (_type) {
			case startStop:		new PlayLevelButton();
			case reset:			new ResetLevelButton();
			case levelSelect:	new FastEntity("icon_level_select");
			case sound:			new SoundButton();
			case home:			new FastEntity("icon_home");
			case pause:			new FastEntity("icon_pause");
			case settings:		new FastEntity("icon_settings");
			case next:			new FastEntity("icon_next");
		}
		icon.mouseEnabled = false;
		icon.y = (height - icon.height) / 2;
		if (_size == 999)	icon.x = icon.y;
		else				icon.x = (width - icon.width) / 2;
		addChild(icon);
	}
	
	override public function clickHandler () :Void {
		if (Std.is(icon, SoundButton) || Std.is(icon, PlayLevelButton))	icon.clickHandler();
		super.clickHandler();
	}
	
}

enum ButtonType {
	startStop;
	reset;
	levelSelect;
	sound;
	home;
	pause;
	settings;
	next;
}
