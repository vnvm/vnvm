package reflash.display;

class DisplayObjectContainer2 extends DisplayObject2 {
    private var childs:Array<DisplayObject2>;

    public function new() {
        super();
        childs = [];
    }

    public var numChildren(get, never):Int;

    private function get_numChildren():Int {
        return childs.length;
    }

    public function getChildAt(index:Int):DisplayObject2 {
        return childs[index];
    }

    public function removeChildren():DisplayObjectContainer2 {
        for (child in childs) child.parent = null;
        childs = [];
        return this;
    }

    public function removeChild(child:DisplayObject2):DisplayObjectContainer2 {
        if (child.parent == this) {
            childs.remove(child);
            child.parent = null;
        }
        return this;
    }

    public function addChild(child:DisplayObject2):DisplayObjectContainer2 {
        if (child.parent != null) {
            child.parent.removeChild(child);
        }
        childs.push(child);
        child.parent = this;
        resort(child);
        return this;
    }

    public function contains(child:DisplayObject2):Bool {
        return Lambda.has(childs, child);
    }

    public function resort(child:DisplayObject2):Void {
        childs.sort(function(a:DisplayObject2, b:DisplayObject2):Int {
            return 0;
            return a.zIndex - b.zIndex;
        });
    }

    override public function drawInternal(drawContext:DrawContext):Void {
        drawContext.modelViewMatrix.prependTranslation(-anchorX * width, -anchorY * height, 0);

//Log.trace('------------------');
        for (child in childs) {
//Log.trace(child);
            child.drawElement(drawContext);
        }
    }
}
