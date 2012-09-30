package engines.ethornell;

import common.StringEx;

/**
 * ...
 * @author soywiz
 */

class MNode
{
	var value:Int;
	var freq:Int;
	var level:Int;
	var encode:Int;
	var parent:MNode;
	var childLeft:MNode;
	var childRight:MNode;
	
	public function opCmp(that:MNode):Int {
		var r:Int = this.freq - that.freq;
		if (r == 0) return this.value - that.value;
		return r;
	}
	
	public function new(value:Int, freq:Int, level:Int = 0) {
		this.value = value;
		this.freq  = freq;
		this.level = level;
	}
	
	public toString():String {
		return StringEx.sprintf(
			"(%08X, %08X, %08X, %010b, [%d, %d])",
			[value, freq, level, encode, (childLeft != null), (childRight != null)]
		);
	}
	
	static public function show(Array<MNode> nodes):Void {
		for (node in nodes) trace(node);
	}
	
	public function leaf():Bool {
		return (childLeft == null) && (childRight == null);
	}
	
	static public function findWithoutParent(nodes:Array<MNode>, start:Int = 0):Int {
		for (pos, node; nodes.slice(start)) {
			if (node.parent == null) {
				return start + pos;
			}
		}
		return -1;
	}
	
	public function propagateLevels(level:Int = 0, encode:Int = 0):Void {
		this.level  = level;
		this.encode = encode;

		if (childLeft  != null) childLeft .propagateLevels(level + 1, (encode << 1) | 0);
		if (childRight != null) childRight.propagateLevels(level + 1, (encode << 1) | 1);
	}
}
