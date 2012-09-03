package common;

/**
 * ...
 * @author soywiz
 */

private class XRange {
	var min : Int;
    var max : Int;
	var step : Int;

    public function new( min : Int, max : Int, step : Int ) {
        this.min = min;
        this.max = max;
		this.step = step;
    }

    public function hasNext() {
        return min < max;
    }

    public function next() {
		var ret:Int = min;
        min += step;
		return ret;
    }
	
}

class IteratorUtilities 
{
	static public function xrange(start:Int, stop:Int, step:Int = 1):Iterator<Int> {
		return new XRange(start, stop, step);
	}
}