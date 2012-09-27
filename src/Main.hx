package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

/**
 * ...
 * @author 01101101
 */

class Main
{
	
	static function main () {
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
	}
	
}