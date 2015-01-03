package engines.brave.sprites;
import reflash.display2.Seconds;
import reflash.display2.Milliseconds;
import reflash.display2.View;
import common.display.SpriteUtils;
import lang.StringEx;
import engines.brave.BraveAssets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * ...
 * @author 
 */

class TextSprite extends View
{
	var picture:Sprite;
	var textContainer:Sprite;
	var textBackground:Sprite;
	var titleTextField:TextField;
	var textTextField:TextField;
	var padding:Int = 16;
	var boxWidth:Int = 600;
	var boxHeight:Int = 100;
	var animateText:Bool = false;

	public function new() 
	{
		super();
		
		textContainer = new Sprite();
		textBackground = new Sprite();
		textTextField = new TextField();
		picture = new Sprite();
		picture.x = -30;
		picture.y = 480;
		
		textTextField.defaultTextFormat = new TextFormat("Lucida Console", 16, 0xFFFFFF);
		textTextField.selectable = false;
		textTextField.multiline = true;
		textTextField.text = "";
		
		setTextSize(false);
		
		//textField.textColor = 0xFFFFFF;
		
		this.alpha = 0;

		textContainer.addChild(textBackground);
		textContainer.addChild(textTextField);

		addChild(picture);
		addChild(textContainer);
	}
	
	private function setTextSize(withFace:Bool):Void {
		var faceWidth:Int = withFace ? 155 : 0;
		
		SpriteUtils.extractSpriteChilds(textBackground);
		textBackground.addChild(SpriteUtils.createSolidRect(0x000000, 0.5, boxWidth - faceWidth, boxHeight));
		
		textContainer.x = 640 / 2 - boxWidth / 2 + faceWidth;
		textContainer.y = 480 - boxHeight - 20;

		textTextField.width = boxWidth - padding * 2 - faceWidth;
		textTextField.height = boxHeight - padding * 2;
		textTextField.x = padding;
		textTextField.y = padding;
	}
	
	private function _setText(text:String):Void
	{
		textTextField.text = text;
	}
	
	private function setText(faceId:Int, title:String, text:String, done:Void -> Void):Void {
		if (animateText) 
		{
			this.animateAsync(new Milliseconds(text.length * 10), function(ratio:Float) {
				var showChars = Math.round(text.length * ratio);
				_setText(text.substr(0, showChars));
			}).then(function(v) {
				done();
			});
		}
		else
		{
			_setText(textTextField.text);
			done();
		}
	}

	public function _setTextAndEnable(faceId:Int, title:String, text:String, done:Void -> Void):Void {
		enable(function() {
			setText(faceId, title, text, done);
		});
	}

	public function setTextAndEnable(faceId:Int, title:String, text:String, done:Void -> Void):Void {
		SpriteUtils.extractSpriteChilds(picture);
		setTextSize(faceId >= -1);
		if (faceId >= 0) {
			BraveAssets.getBitmapDataWithAlphaCombinedAsync(StringEx.sprintf("Z_%02d_%02d", [Std.int(faceId / 100), Std.int(faceId % 100)])).then(function(bitmapData:BitmapData) {
				var bmp:Bitmap = SpriteUtils.center(new Bitmap(bitmapData, PixelSnapping.AUTO, true), 0, 1);
				picture.addChild(bmp);
				_setTextAndEnable(faceId, title, text, done);
			});
		} else {
			_setTextAndEnable(faceId, title, text, done);
		}
	}

	public function enable(done:Void -> Void):Void
	{
		if (alpha != 1) {
			interpolateAsync(this, new Seconds(0.3), { alpha : 1 }).then(function(v) {
				done();
			});
		} else {
			done();
		}
	}
	
	public function endText():Void {
		textTextField.text = "";
	}

	public function disable(done:Void -> Void):Void {
		var done2 = function() {
			endText();
			done();
		};
		if (alpha != 0) {
			interpolateAsync(this, new Seconds(0.1), { alpha : 0 }).then(function(v) {
				done2();
			});
		} else {
			done2();
		}
	}
}