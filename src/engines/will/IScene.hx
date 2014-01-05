package engines.will;

import lang.promise.IPromise;
import engines.will.display.IGameElementsLayer;
import engines.will.display.GameElementsLayer;
import reflash.display.Sprite2;
import flash.geom.Point;
import flash.utils.ByteArray;

interface IScene
{
	function getMaskValueAt(point:Point):Int;
	function getMousePosition():Point;

	function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):IPromise<Dynamic>;
	function getBtyeArrayAsync(name:String):IPromise<ByteArray>;
	function setTransitionMaskAsync(name:String):IPromise<Dynamic>;

	function getLayerWithName(name:String):IGameElementsLayer;

	function performTransitionAsync(kind:Int, time:Int):IPromise<Dynamic>;

	function setTextAsync(text:String, timePerCharacter:Float):IPromise<Dynamic>;

	function animLoadAsync(name:String):IPromise<Dynamic>;
	function tableLoadAsync(name:String):IPromise<Dynamic>;

	function setAnimObjectVisibility(index:Int, visible:Bool):IPromise<Dynamic>;
	function setDirectMode(directMode:Bool):Void;
	function isEnabledKind(kind:Int):Bool;
}