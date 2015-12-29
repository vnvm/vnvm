package common.input;

import lang.signal.Signal;
import haxe.Log;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
 * ...
 * @author 
 */

class GameInput 
{
	static var pressing:Map<Int,Void>;
	static var lastPressing:Map<Int,Void>;

	private function new() 
	{
	}
	
	static public var onClick:Signal<MouseEvent>;
	static public var onMouseMoveEvent:Signal<MouseEvent>;
	static public var onKeyPress:Signal<KeyboardEvent>;
	static public var onKeyRelease:Signal<KeyboardEvent>;
	static public var onKeyPressing:Signal<KeyboardEvent>;
	
	static public function init() {
		pressing = new Map<Int,Void>();
		lastPressing = new Map<Int,Void>();
		StageReference.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			setKey(e.keyCode, true);
		});
		StageReference.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
			setKey(e.keyCode, false);
		});
		StageReference.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		StageReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		StageReference.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		StageReference.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		StageReference.stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			onClick.dispatch(e);
		});
		StageReference.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			//onClick.trigger(e);
		});
		
		mouseCurrent = new Point(-1, -1);
		mouseCurrentClick = new Point( -1, -1);
		mouseStart = new Point(-1, -1);
		onClick = new Signal<MouseEvent>();
		onMouseMoveEvent = new Signal<MouseEvent>();
		onKeyPress = new Signal<KeyboardEvent>();
		onKeyRelease = new Signal<KeyboardEvent>();
		onKeyPressing = new Signal<KeyboardEvent>();
	}
	
	static public function onEnterFrame(e:Event):Void {
		for (key in lastPressing.keys()) {
			if (pressing.exists(key)) {
			} else {
				lastPressing.remove(key);
				onKeyRelease.dispatch(new KeyboardEvent("onRelease", true, false, 0, key));
			}
		}
		for (key in pressing.keys()) {
			if (lastPressing.exists(key)) {
				onKeyPressing.dispatch(new KeyboardEvent("onPressing", true, false, 0, key));
			} else {
				lastPressing.set(key, null);
				onKeyPress.dispatch(new KeyboardEvent("onPress", true, false, 0, key));
			}
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

		onMouseMoveEvent.dispatch(e);
	}
}