package reflash.display2;

import openfl.Lib;
class TimeMeasure {
    static public function measure(callback: Void -> Void):Float {
        var start = Lib.getTimer();
        callback();
        var end = Lib.getTimer();
        return (end - start) / 1000;
    }
}
