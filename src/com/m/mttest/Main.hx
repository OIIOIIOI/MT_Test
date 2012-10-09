package com.m.mttest;

import com.m.mttest.anim.FrameManager;
import com.remixtechnology.SWFProfiler;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.ui.ContextMenu;

/**
 * ...
 * @author 01101101
 */

@:bitmap("res/tiles.png") class TilesSheet extends flash.display.BitmapData { }
@:bitmap("res/levels.png") class LevelsSheet extends flash.display.BitmapData { }
@:bitmap("res/font_volter.png") class FontVolterSheet extends flash.display.BitmapData { }
@:bitmap("res/font_superscript.png") class FontSuperscriptSheet extends flash.display.BitmapData { }
@:bitmap("res/font_numbers_red.png") class FontNumbersRedSheet extends flash.display.BitmapData { }
@:bitmap("res/font_numbers_blue.png") class FontNumbersBlueSheet extends flash.display.BitmapData { }
@:bitmap("res/font_numbers_gold.png") class FontNumbersGoldSheet extends flash.display.BitmapData { }
@:bitmap("res/tutos.png") class TutosSheet extends flash.display.BitmapData { }
@:bitmap("res/background.png") class BGSheet extends flash.display.BitmapData { }

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
		FrameManager.store("font_numbers_red", new FontNumbersRedSheet(0, 0), haxe.Resource.getString("fontNumbersJson"));
		FrameManager.store("font_numbers_blue", new FontNumbersBlueSheet(0, 0), haxe.Resource.getString("fontNumbersJson"));
		FrameManager.store("font_numbers_gold", new FontNumbersGoldSheet(0, 0), haxe.Resource.getString("fontNumbersJson"));
		FrameManager.store("tutos", new TutosSheet(0, 0), haxe.Resource.getString("tutosJson"));
		FrameManager.store("background", new BGSheet(0, 0), haxe.Resource.getString("backgroundJson"));
		// Create and add game
		Lib.current.stage.addChild(new Game());
		// Profiler and context menu
		#if debug
		SWFProfiler.init();
		#else
		Lib.current.contextMenu = new ContextMenu();
		Lib.current.contextMenu.hideBuiltInItems();
		#end
	}
	
}
