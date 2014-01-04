package engines.will;

import engines.will.display.IGameElementsLayer;
import engines.will.display.GameElementsLayer;
import reflash.display.Sprite2;
import flash.geom.Point;
import flash.utils.ByteArray;
import promhx.Promise;

interface IScene
{
	function getMaskValueAt(point:Point):Int;
	function getMousePosition():Point;

	function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):Promise<Dynamic>;
	function getBtyeArrayAsync(name:String):Promise<ByteArray>;
	function setTransitionMaskAsync(name:String):Promise<Dynamic>;

	function getLayerWithName(name:String):IGameElementsLayer;

	function performTransitionAsync(kind:Int, time:Int):Promise<Dynamic>;

	function setTextAsync(text:String):Promise<Dynamic>;

	function animLoadAsync(name:String):Promise<Dynamic>;
	function tableLoadAsync(name:String):Promise<Dynamic>;

	function setAnimObjectVisibility(index:Int, visible:Bool):Promise<Dynamic>;
	function setDirectMode(directMode:Bool):Void;
	function isEnabledKind(kind:Int):Bool;
}