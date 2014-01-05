package engines.will.display;

import lang.promise.IPromise;
import common.geom.Anchor;

interface IGameElementsLayer
{
	function removeObject(index:Int):Void;
	function putObjectAsync(index:Int, x:Int, y:Int, name:String, anchor:Anchor):IPromise<Dynamic>;
	function setObjectPos(index:Int, x:Int, y:Int):GameElementsLayer;
	function setObjectSizeRotation(index:Int, scale:Float, rotation:Float):GameElementsLayer;
	function setLayerViewPort(scale:Float, x:Int, y:Int):GameElementsLayer;
}
