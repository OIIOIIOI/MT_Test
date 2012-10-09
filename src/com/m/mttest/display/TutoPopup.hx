package com.m.mttest.display;

import com.m.mttest.entities.Entity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.Game;
import flash.geom.Point;

/**
 * ...
 * @author 01101101
 */

class TutoPopup extends Entity
{
	
	private var tuto:Tuto;
	private var step:Int;
	
	private var mainLayer:Entity;
	private var upperLayer:Entity;
	
	public function new (_tuto:Tuto) {
		super();
		// Main layer
		mainLayer = new Entity();
		addChild(mainLayer);
		// Upper layer
		upperLayer = new Entity();
		upperLayer.color = 0x00FF00FF;
		upperLayer.width = Std.int(Game.SIZE.width);
		upperLayer.height = Std.int(Game.SIZE.height);
		upperLayer.customClickHandler = layerClickHandler;
		addChild(upperLayer);
		//
		tuto = _tuto;
		step = -1;
		nextStep();
	}
	
	private function layerClickHandler (_target:Entity) :Void {
		//trace("layerClickHandler");
		nextStep();
	}
	
	private function nextStep () {
		var _e:FastEntity;
		while (mainLayer.numChildren > 0) {
			mainLayer.removeChildAt(0);
		}
		//
		step++;
		switch (tuto) {
			case Tuto.tutoStart:
			{
				if (step == 0) {
					_e = new FastEntity("tuto_start0", "tutos");
					mainLayer.addChild(_e);
				}
				else if (step == 1) {
					_e = new FastEntity("tuto_start1", "tutos");
					mainLayer.addChild(_e);
				}
				else if (step == 2) {
					_e = new FastEntity("tuto_start2", "tutos");
					mainLayer.addChild(_e);
				}
				else {
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.EXIT_TUTO));
				}
			}
			case Tuto.tutoTime:
			{
				if (step == 0) {
					_e = new FastEntity("tuto_time", "tutos");
					mainLayer.addChild(_e);
				}
				else {
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.EXIT_TUTO));
				}
			}
			case Tuto.tutoRock:
			{
				if (step == 0) {
					_e = new FastEntity("tuto_rock", "tutos");
					mainLayer.addChild(_e);
				}
				else {
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.EXIT_TUTO));
				}
			}
			case Tuto.tutoHole:
			{
				if (step == 0) {
					_e = new FastEntity("tuto_hole", "tutos");
					mainLayer.addChild(_e);
				}
				else {
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.EXIT_TUTO));
				}
			}
			case Tuto.tutoBigBomb:
			{
				if (step == 0) {
					_e = new FastEntity("tuto_big_bomb", "tutos");
					mainLayer.addChild(_e);
				}
				else {
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.EXIT_TUTO));
				}
			}
			case Tuto.tutoChain:
			{
				if (step == 0) {
					_e = new FastEntity("tuto_chain", "tutos");
					mainLayer.addChild(_e);
				}
				else {
					EventManager.instance.dispatchEvent(new GameEvent(GameEvent.EXIT_TUTO));
				}
			}
		}
	}
	
}

enum Tuto {
	tutoStart;
	tutoTime;
	tutoRock;
	tutoHole;
	tutoBigBomb;
	tutoChain;
}
