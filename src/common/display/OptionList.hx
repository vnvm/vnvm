package common.display;
import common.Event2;
import common.GameInput;
import common.SpriteUtils;
import haxe.Log;
import nme.display.Sprite;
import nme.display.Stage;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * ...
 * @author soywiz
 */

class OptionList
{
	public var sprite:Sprite;
	public var rows:Int;
	public var columns:Int;
	public var width:Int;
	public var height:Int;
	public var fillRowsThenColumns:Bool;
	public var options:Array<Option>;
	
	public var visible(_getVisible, _setVisible):Bool;
	private function _getVisible():Bool { return sprite.visible; }
	private function _setVisible(value:Bool):Bool { return sprite.visible = value; }
	
	public var onSelected:Event2<OptionSelectedEvent>;
	

	public function new(width:Int, height:Int, rows:Int, columns:Int, fillRowsThenColumns:Bool) 
	{
		this.width = width;
		this.height = height;
		this.rows = rows;
		this.columns = columns;
		this.fillRowsThenColumns = fillRowsThenColumns;
		this.onSelected = new Event2<OptionSelectedEvent>();
		this.sprite = new Sprite();
		Lib.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseUpdate);
		Lib.stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseUpdate);
		Lib.stage.addEventListener(MouseEvent.CLICK, onMouseClick);
		clear();
	}
	
	private function onMouseUpdate(e:MouseEvent):Void {
		var pos:Point = sprite.globalToLocal(new Point(e.stageX, e.stageY));
		var index:Int = getIndexForPoint(pos);
		//Log.trace(Std.format("(${pos.x}, ${pos.y}), (${width}, ${height}) : $index"));
		for (n in 0 ... options.length) {
			options[n].selected = (n == index);
		}
	}
	
	private function onMouseClick(e:MouseEvent):Void {
		var pos:Point = sprite.globalToLocal(new Point(e.stageX, e.stageY));
		var index:Int = getIndexForPoint(pos);
		if (index >= 0) {
			onSelected.trigger(new OptionSelectedEvent(options[index]));
		}
	}
	
	private function getAreaForIndex(index:Int):Rectangle {
		var row:Int;
		var column:Int;
		var cellWidth:Int = Std.int(width / columns);
		var cellHeight:Int = Std.int(height / rows);
		
		if (fillRowsThenColumns) {
			column = Std.int(index % rows);
			row = Std.int(index / rows);
		} else {
			row = Std.int(index % columns);
			column = Std.int(index / columns);
		}
		
		return new Rectangle(row * cellWidth, column * cellHeight, cellWidth, cellHeight);
	}
	
	private function getIndexForPoint(point:Point):Int {
		for (n in 0 ... options.length) {
			var rect:Rectangle = getAreaForIndex(n);
			if (rect.containsPoint(point)) {
				return n;
			}
		}
		return -1;
	}
	
	public function clear():Void {
		SpriteUtils.removeSpriteChilds(this.sprite);
		this.options = [];
	}
	
	public function addOption(text:String, data:Dynamic):Void {
		var rect:Rectangle = getAreaForIndex(options.length);
		var option:Option = new Option(options.length, rect, text, data);
		options.push(option);
		sprite.addChild(option.sprite);
	}
}