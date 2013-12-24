package vfs;

import promhx.Promise;
import vfs.utils.LangUtils;
import flash.utils.ByteArray;
import vfs.Stream;

/**
 * ...
 * @author soywiz
 */

class SliceStream extends Stream
{
	public var parent:Stream;
	private var start:Int;

	private function new(parent:Stream) 
	{
		this.parent = parent;
	}
	
	override public function readBytesAsync(length:Int):Promise<ByteArray> 
	{
		var parentOldPosition:Int = parent.position;
		
		parent.position = this.start + this.position;
		return parent.readBytesAsync(length).then(function(bytes:ByteArray) {
			this.position = parent.position - this.start;
			parent.position = parentOldPosition;
			return bytes;
		});
	}
	
	static public function fromLength(parent:Stream, low:Int, length:Int):SliceStream
	{
		var sliceStream:SliceStream = new SliceStream(parent);
		sliceStream.position = 0;
		sliceStream.start = low;
		sliceStream.length = length;
		return sliceStream;
	}
	
	static public function fromBounds(parent:Stream, low:Int, high:Int):SliceStream
	{
		return fromLength(parent, low, high - low);
	}
	
	static public function fromAll(parent:Stream):SliceStream
	{
		return fromLength(parent, 0, parent.length);
	}
}