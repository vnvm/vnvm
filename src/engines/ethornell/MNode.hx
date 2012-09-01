package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

class MNode {
	union {
		struct { int value, freq;  }
		long freq_value;
	}
	int level;
	uint encode;
	MNode parent;
	MNode childs[2];
	int opCmp(Object o) { MNode that = cast(MNode)o;
		//return this.freq_value - that.freq_value;
		int r = this.freq - that.freq;
		if (r == 0) return this.value - that.value;
		return r;
	}
	this(int value, int freq, int level = 0) {
		this.value = value;
		this.freq  = freq;
		this.level = level;
	}
	char[] toString() { return format("(%08X, %08X, %08X, %010b, [%d, %d])", value, freq, level, encode, childs[0] !is null, childs[1] !is null); }
	static void show(MNode[] nodes) {
		foreach (node; nodes) writefln(node);
	}
	bool leaf() { return (childs[0] is null) && (childs[1] is null); }
	static int findWithoutParent(MNode[] nodes, int start = 0) {
		foreach (pos, node; nodes[start..nodes.length]) if (node.parent is null) return start + pos;
		return -1;
	}
	void propagateLevels(int level = 0, uint encode = 0) {
		this.level  = level;
		this.encode = encode;
		foreach (k, node; childs) if (node !is null) node.propagateLevels(level + 1, (encode << 1) | k);
		//foreach (k, node; childs) if (node !is null) node.propagateLevels(level + 1, encode | (k << level));
	}
}
