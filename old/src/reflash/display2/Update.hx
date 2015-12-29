package reflash.display2;

import flash.events.Event;
import openfl.Lib;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;

class Update {
    public var dt:Float = 0;
    public var dtMs:Int = 0;
    public var totalMs:Float = 0;

    public function update(d:DisplayObject):Void {
        if (Std.is(d, Updatable)) {
            cast(d, Updatable).update(this);
        }
        if (Std.is(d, DisplayObjectContainer)) {
            var ds = cast(d, DisplayObjectContainer);
            for (n in 0 ... ds.numChildren) update(ds.getChildAt(n));
        }
    }

    static public function init(root:DisplayObject) {
        var update = new Update();
        var last = Lib.getTimer();
        trace('Update init');
        root.stage.addEventListener(Event.ENTER_FRAME, function(e) {
            var current = Lib.getTimer();
            var elapsed = current - last;
            last = current;
            update.dtMs = Std.int(Math.min(elapsed, 40));
            update.dt = update.dtMs;
            update.totalMs = current;
            update.update(root);
        });
    }
}
