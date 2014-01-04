package common.input;

import haxe.Log;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import common.event.Event2;

/**
 * ...
 * @author 
 */

class GameInput 
{
	static var pressing:Map<Int,Void>;

	private function new() 
	{
	}
	
	static public var onClick:Event2<MouseEvent>;
	static public var onMouseMoveEvent:Event2<MouseEvent>;
	static public var onKeyPress:Event2<KeyboardEvent>;
	
	static public function init() {
		pressing = new Map<Int,Void>();
		StageReference.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		StageReference.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		StageReference.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		StageReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		StageReference.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		StageReference.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		StageReference.stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			onClick.trigger(e);
		});
		StageReference.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			//onClick.trigger(e);
		});
		
		mouseCurrent = new Point(-1, -1);
		mouseCurrentClick = new Point( -1, -1);
		mouseStart = new Point(-1, -1);
		onClick = new Event2<MouseEvent>();
		onMouseMoveEvent = new Event2<MouseEvent>();
		onKeyPress = new Event2<KeyboardEvent>();
	}
	
	static public function onEnterFrame(e:Event):Void {
		for (key in pressing.keys()) {
			onKeyPress.trigger(new KeyboardEvent("onPress", true, false, 0, key));
		}
	}
	
	static public function isPressing(keyCode:Int):Bool {
		return pressing.exists(keyCode);
	}
	
	static private function setKey(key:Int, set:Bool):Void {
		if (set) {
			pressing.set(key, null);
		} else {
			pressing.remove(key);
		}
	}
	
	static private function onKeyDown(e:KeyboardEvent):Void  {
		setKey(e.keyCode, true);
	}
	
	static private function onKeyUp(e:KeyboardEvent):Void  {
		setKey(e.keyCode, false);
	}
	
	static public var mouseCurrent:Point;
	static public var mouseCurrentClick:Point;
	static public var mouseStart:Point;
	
	static private function onMouseDown(e:MouseEvent):Void {
		if (e.buttonDown) {
			//Log.trace(Std.format("onMouseDown : ${e.stageX}, ${e.stageY}"));
			mouseStart = new Point(e.stageX, e.stageY);
			//e.stageX
		}
	}

	static private function onMouseUp(e:MouseEvent):Void {
		//Log.trace(Std.format("onMouseUp : ${e.stageX}, ${e.stageY}"));
		setKey(Keys.Left, false);
		setKey(Keys.Right, false);
		setKey(Keys.Up, false);
		setKey(Keys.Down, false);
	}
	
	static private inline var deltaThresold:Int = 40;

	static private function onMouseMove(e:MouseEvent):Void {
		mouseCurrent = new Point(e.stageX, e.stageY);
		if (e.buttonDown) {
			//Log.trace(Std.format("onMouseMove : ${e.stageX}, ${e.stageY}"));
			mouseCurrentClick = new Point(e.stageX, e.stageY);
			var offset:Point = mouseCurrentClick.subtract(mouseStart);
			
			//Log.trace(Std.format("--> ${offset.x}, ${offset.y}"));
			
			setKey(Keys.Left, (offset.x < -deltaThresold));
			setKey(Keys.Right, (offset.x > deltaThresold));
			setKey(Keys.Up, (offset.y < -deltaThresold));
			setKey(Keys.Down, (offset.y > deltaThresold));
		}

		onMouseMoveEvent.trigger(e);
	}
}