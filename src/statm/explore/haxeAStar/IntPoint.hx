package statm.explore.haxeAStar;

/**
 * 整数坐标。
 *
 * @author statm
 */

class IntPoint
{
	public var x:Int;
	public var y:Int;
	
	public function new(_x:Int = 0, _y:Int = 0)
	{
		x = _x;
		y = _y;
	}
	
	public function equals(pt:IntPoint):Bool
	{
		return (x == pt.x && y == pt.y);
	}
	
	public function toString():String
	{
		return "(" + this.x + "," + this.y + ")";
	}
}