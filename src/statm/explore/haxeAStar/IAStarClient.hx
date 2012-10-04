package statm.explore.haxeAStar;

/**
 * A* 数据源。
 *
 * @author statm
 */

interface IAStarClient
{
	var rowTotal(default, never):Int;
	
	var colTotal(default, never):Int;
	
	var allowDiag(default, never):Bool;
	
	function isWalkable(x:Int, y:Int):Bool;
}