package com.m.mttest.display;

import com.m.mttest.display.Button;
import com.m.mttest.entities.Entity;
import com.m.mttest.events.EventManager;
import com.m.mttest.events.GameEvent;
import com.m.mttest.fx.ColorFX;
import com.m.mttest.Game;
import flash.geom.ColorTransform;

/**
 * ...
 * @author 01101101
 */

class EndGameScreen extends Entity
{
	
	private var title:FastEntity;
	private var lineA:BitmapText;
	private var lineB:BitmapText;
	private var back:Button;
	private var replay:Button;
	private var next:Button;
	
	public function new (_victory:Bool, ?_reason:Int, _unlock:Bool = false) {
		super();
		// Background
		//color = 0xCC00000F;
		color = 0xBBF2F9FF;
		width = Std.int(Game.SIZE.width / Game.SCALE);
		height = Std.int(Game.SIZE.height / Game.SCALE);
		// Title
		title = (_victory) ? new FastEntity("title_cleared") : new FastEntity("title_failed");
		title.scale = 2;
		title.x = (Game.SIZE.width / Game.SCALE - title.width * title.scale) / 2;
		title.y = 32;
		addChild(title);
		// Text
		var _text:String = switch (_reason) {
			case 0:		"Some sheep did not make it...";
			case 1:		"A poor sheep was injured...";
			case 2:		"Some poor sheep were injured...";
			default:	"The sheep made it to their destination!";
		}
		lineA = new BitmapText(_text);
		lineA.scale = 2;
		lineA.x = (Game.SIZE.width - lineA.width) / 2;
		lineA.y = Game.SIZE.height / 2 - 16;
		// Text unlock
		if (_unlock) {
			lineA.y -= 16;
			lineB = new BitmapText("Next level unlocked!");
			lineB.scale = 2;
			lineB.x = (Game.SIZE.width - lineB.width) / 2;
			lineB.y = lineA.y + 32;
		}
		// Exit to menu
		back = new Button(18, ButtonType.levelSelect);
		back.customClickHandler = backClickHandler;
		addChild(back);
		// Replay
		if (_victory)	replay = new Button(18, ButtonType.reset);
		else			replay = new Button(24, ButtonType.reset);
		replay.icon.play("on");
		replay.customClickHandler = replayClickHandler;
		addChild(replay);
		// Next (display if next level is unlocked or this was the last level
		if ((Game.CURRENT_LEVEL + 1 < Game.LEVELS.length && !Game.LEVELS[Game.CURRENT_LEVEL + 1].locked)
			|| (_victory && Game.CURRENT_LEVEL + 1 >= Game.LEVELS.length))
		{
			// Big if victory
			if (_victory)	next = new Button(24, ButtonType.next);
			else			next = new Button(18, ButtonType.next);
			next.customClickHandler = nextClickHandler;
			addChild(next);
		}
		// Place buttons
		if (next != null)	replay.x = (Game.SIZE.width / Game.SCALE - replay.width) / 2;
		else				replay.x = (Game.SIZE.width / Game.SCALE) / 2 + 2;
		replay.y = Game.SIZE.height / Game.SCALE - 24 - 32;
		back.x = replay.x - back.width - 4;
		back.y = replay.y + (replay.height - back.height) / 2;
		if (next != null) {
			next.x = replay.x + replay.width + 4;
			next.y = replay.y + (replay.height - next.height) / 2;
		}
	}
	
	public function addedToScene () :Void {
		if (lineA != null) {
			lineA.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 71, 80, 89)), true, true);
			TextLayer.instance.addChild(lineA);
		}
		if (lineB != null) {
			lineB.addFX(new ColorFX(-1, new ColorTransform(0, 0, 0, 1, 156, 107, 0)), true, true);
			TextLayer.instance.addChild(lineB);
		}
	}
	
	private function replayClickHandler (e:Entity) {
		EventManager.instance.dispatchEvent(new GameEvent(GameEvent.RESET_LEVEL));
	}
	private function backClickHandler (e:Entity) {
		EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.levelSelect } ));
	}
	private function nextClickHandler (e:Entity) {
		if (Game.CURRENT_LEVEL + 1 >= Game.LEVELS.length)
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.ending} ));
		else
			EventManager.instance.dispatchEvent(new GameEvent(GameEvent.CHANGE_SCENE, { scene:GameScene.play, param:Game.CURRENT_LEVEL + 1 } ));
	}
	
	override public function destroy () :Void {
		if (lineA != null)	TextLayer.instance.removeChild(lineA);
		super.destroy();
	}
	
}
