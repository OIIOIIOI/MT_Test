package com.m.mttest.display;

import com.m.mttest.entities.Entity;
import com.m.mttest.entities.LevelEntity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.fx.ColorFX;
import com.m.mttest.Game;
import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class Hint extends Entity
{
	
	private var background:FastEntity;
	private var lineA:BitmapText;
	private var lineB:BitmapText;
	private var colorFX:ColorFX;
	
	public var lines (default, setLines):Array<String>;
	
	public function new () {
		super();
		mouseEnabled = false;
		//
		background = new FastEntity("bg_hint");
		background.scale = 3;
		background.x = (Game.SIZE.width - background.width * background.scale) / 2;
		addChild(background);
		//
		lineA = new BitmapText(" ");
		lineA.mouseEnabled = false;
		lineA.scale = 2;
		lineB = new BitmapText(" ");
		lineB.mouseEnabled = false;
		lineB.scale = 2;
		lineB.y = 20;
		addChild(lineA);
		addChild(lineB);
		//
		colorFX = new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 80, 50, 25));
		//
		lines = ["Click an object to read its description"];
		EventManager.instance.addEventListener(GameEvent.SET_HINT, setHintHandler);
	}
	
	override public function destroy () :Void {
		EventManager.instance.removeEventListener(GameEvent.SET_HINT, setHintHandler);
		super.destroy();
	}
	
	private function setHintHandler (_event:GameEvent) :Void {
		lines = _event.data;
	}
	
	private function setLines (_lines:Array<String>) :Array<String> {
		lines = _lines;
		// Line A
		lineA.text = _lines[0];
		lineA.x = (Game.SIZE.width - lineA.width) / 2;
		// Line B
		if (_lines.length > 1) {
			lineB.text = _lines[1];
			lineB.x = (Game.SIZE.width - lineB.width) / 2;
			addChild(lineB);
			lineA.y = 9;
			lineB.y = lineA.y + 20;
		}
		else {
			lineB.text = " ";
			removeChild(lineB);
			lineA.y = 19;
		}
		lineA.removeFX(null, true);
		lineB.removeFX(null, true);
		lineA.addFX(colorFX, true, true);
		lineB.addFX(colorFX, true, true);
		return lines;
	}
	
}