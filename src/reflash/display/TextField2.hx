package reflash.display;

import flash.filters.GlowFilter;
import flash.text.TextFieldAutoSize;
import reflash.gl.IGLTextureBase;
import lang.DisposableHolder;
import reflash.gl.IGLTexture;
import reflash.gl.wgl.WGLTexture;
import flash.display.BitmapData;
import flash.text.TextFormat;
import flash.text.TextField;

class TextField2 extends DisplayObject2
{
	public var text:String;
	private var textField:TextField;

	private var cachedText:String;
	private var cachedTexture:DisposableHolder<IGLTexture>;

	public function new()
	{
		super();
		this.textField = new TextField();
		this.cachedText = "";
		this.cachedTexture = new DisposableHolder<IGLTexture>();
	}

	override private function drawInternal(drawContext:DrawContext)
	{
		if (cachedText != text)
		{
			cachedText = text;

			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.multiline = true;
			var format = new TextFormat();
			format.font = "Lucida Console";
			format.size = 19;
			format.color = 0xFFFFFFFF;
			format.leading = 14;
			textField.defaultTextFormat = format;
			textField.filters = [
				new GlowFilter(0x000000, 1, 2, 2, 1000)
			];
			textField.text = text;
			//var metrics = textField.getLineMetrics(0);

			//var metrics = textField.getLineMetrics(0);
			//var characterBitmapData = new BitmapData(Std.int(metrics.width), Std.int(metrics.height), true, 0x00000000);
			var characterBitmapData = new BitmapData(Std.int(textField.width), Std.int(textField.height), true, 0x00000000);
			characterBitmapData.draw(textField);

			cachedTexture.set(WGLTexture.fromBitmapData(characterBitmapData));
		}

		new Image2(cachedTexture.value).drawInternal(drawContext);
	}
}
