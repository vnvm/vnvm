package common.display;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;

/**
 * ...
 * @author soywiz
 */

class Option
{
	public var index:Int;
	public var sprite:Sprite;
	public var data:Dynamic;
	public var selected(_getSelected, _setSelected):Bool;

	private var textField:TextField;
	private var _selected:Bool = true;

	public function new(index:Int, rect:Rectangle, text:String, data:Dynamic) 
	{
		this.index = index;
		this.textField = new TextField();
		this.textField.selectable = false;
		this.textField.x = rect.x;
		this.textField.y = rect.y;
		this.textField.width = rect.width;
		this.textField.height = rect.height;
		this.textField.text = text;
		this.data = data;
		
		selected = false;
		
		this.sprite = new Sprite();
		//this.sprite.useHandCursor = true;
		this.sprite.addChild(this.textField);
		//this.sprite.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		//this.sprite.addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	/*
	private function onOver(e:MouseEvent):Void {
		selected = true;
	}

	private function onOut(e:MouseEvent):Void {
		selected = false;
	}
	*/
	
	private function _getSelected():Bool {
		return this._selected;
	}

	private function _setSelected(value:Bool):Bool {
		if (this._selected != value) {
			this._selected = value;
			
			this.textField.defaultTextFormat = new TextFormat("Arial", 12, selected ? 0x000000 : 0xFFFFFF);
			this.textField.text = this.textField.text;
			this.textField.background = selected ? true : false;
			//this.textField.opaqueBackground
			this.textField.backgroundColor = selected ? 0xFFFFFFFF : 0xFF000000;
		}
		
		return selected;
	}
}