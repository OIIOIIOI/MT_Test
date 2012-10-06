package com.m.mttest;

import com.m.mttest.anim.FrameManager;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

/**
 * ...
 * @author 01101101
 */

@:bitmap("res/tiles.png") class TilesSheet extends flash.display.BitmapData { }
@:bitmap("res/levels.png") class LevelsSheet extends flash.display.BitmapData { }
@:bitmap("res/font_volter.png") class FontVolterSheet extends flash.display.BitmapData { }
@:bitmap("res/font_superscript.png") class FontSuperscriptSheet extends flash.display.BitmapData { }

class Main
{
	
	static function main () {
		// Init
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		// Keyboard
		KeyboardManager.init(Lib.current.stage);
		// Spritesheets
		FrameManager.store("tiles", new TilesSheet(0, 0), haxe.Resource.getString("tilesJson"));
		FrameManager.store("levels", new LevelsSheet(0, 0), haxe.Resource.getString("levelsJson"));
		FrameManager.store("font_volter", new FontVolterSheet(0, 0), haxe.Resource.getString("fontVolterJson"));
		FrameManager.store("font_superscript", new FontSuperscriptSheet(0, 0), haxe.Resource.getString("fontSuperscriptJson"));
		// Create and add game
		Lib.current.stage.addChild(new Game());
	}
	
}
