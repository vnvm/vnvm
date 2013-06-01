package engines.ethornell;
import common.ByteArrayUtils;
import common.imaging.BmpColor;
import common.LangUtils;
import common.Reference;
import common.StringEx;
import common.Timer2;
import haxe.io.Bytes;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.errors.Error;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.Timer;

/**
 * Class to uncompress "CompressedBG" files.
 * 
 * @author soywiz
 */
class CompressedBG
{
	//static assert(Header.sizeof == 0x30, "Invalid size for CompressedBG.Header");
	//static assert(Node.sizeof   == 24  , "Invalid size for CompressedBG.Node");
	
	var header:Header;
	var data0:ByteArray;
	var table:Array<Int>; // 0x100
	var table2:Array<Node>; // 0x1FF
	var data1:ByteArray;
	public var data:BitmapData;

	/**
	 * 
	 * @param	s
	 */
	public function new(?s:ByteArray)
	{
		if (s != null) load(s);
	}
	
	public function load(s:ByteArray):Void {
		var start:Float = haxe.Timer.stamp();
		
		table = LangUtils.createArray(function():Int { return 0; }, 0x100);
		table2 = LangUtils.createArray(function():Node { return new Node(); }, 0x1FF);

		header = new Header();
		header.readFrom(s);
		//trace(s.bytesAvailable);
		data0 = ByteArrayUtils.readByteArray(s, header.data0_len);
		//trace(s.bytesAvailable);
		var datahf:ByteArray = ByteArrayUtils.readByteArray(s, s.bytesAvailable);

		decode_chunk0(data0, header.data0_val);
		
		// Check the decoded chunk with a hash.
		if (!check_chunk0(data0, header.hash0, header.hash1)) throw(new Error("Invalid chunk0"));
	
		process_chunk0(data0, table, 0x100);
		var method2_res:Int = method2(table, table2);
		var data3:ByteArray = ByteArrayUtils.newByteArrayWithLength(header.w * header.h * 4, Endian.LITTLE_ENDIAN);
		
		data1 = ByteArrayUtils.newByteArrayWithLength(header.data1_len, Endian.LITTLE_ENDIAN);
		uncompress_huffman(datahf, data1, table2, method2_res);
		uncompress_rle(data1, data3);
		
		data = unpack_real(data3);
		
		trace("Load: " + (haxe.Timer.stamp() - start));
	}

	/**
	 * 
	 * @param	data
	 * @param	hash_val
	 */
	static public function decode_chunk0(data:ByteArray, hash_val:Int):Void
	{
		var start:Float = haxe.Timer.stamp();
		
		var hash_val_ref:Reference<Int> = new Reference<Int>(hash_val);
		
		//trace(StringEx.sprintf("%08X", [hash_val]));
		
		for (n in 0 ... data.length)
		{
			var prev:Int = data[n];
			var hash:Int = (Utils.hash_update(hash_val_ref) & 0xFF);
			var next:Int = (data[n] - hash) & 0xFF;
			data[n] = next;
			//trace(StringEx.sprintf("%02X-%02X -> %02X", [prev, hash, next]));
		}
		
		trace("decode_chunk0: " + (haxe.Timer.stamp() - start));
	}
	
	/**
	 * 
	 * @param	data
	 * @param	hash_dl
	 * @param	hash_bl
	 * @return
	 */
	static public function check_chunk0(data:ByteArray, hash_dl:Int, hash_bl:Int):Bool
	{
		var dl:Int = 0;
		var bl:Int = 0;
		
		for (n in 0 ... data.length)
		{
			var c:Int = data[n];
			dl = (dl + c) & 0xFF;
			bl = (bl ^ c) & 0xFF;
		}
		
		//trace(StringEx.sprintf("DL: %08X, %08X", [dl, hash_dl]));
		//trace(StringEx.sprintf("BL: %08X, %08X", [bl, hash_bl]));
		
		return (dl == hash_dl) && (bl == hash_bl);
	}

	/**
	 * 
	 * @param	data0
	 * @param	table
	 * @param	count
	 */
	static public function process_chunk0(data0:ByteArray, table:Array<Int>, count:Int = 0x100)
	{
		for (n in 0 ... count) table[n] = Utils.readVariable(data0);
	}

	/**
	 * 
	 * @param	table1
	 * @param	table2
	 * @return
	 */
	static public function method2(table1:Array<Int>, table2:Array<Node>):Int 
	{
		var start:Float = haxe.Timer.stamp();
		var sum_of_values:Int = 0;
		var node:Node;
		
		{ // Verified.
			for (n in 0 ... 0x100)
			{
				var node:Node = table2[n];
				node.v0 = (table1[n] > 0);
				node.v1 = table1[n];
				node.v2 = false;
				node.v3 =-1;
				node.v4 = n;
				node.v5 = n;
				sum_of_values += table1[n];
				//writefln(table2[n]);
			}
			//writefln(sum_of_values);
			if (sum_of_values == 0) return -1;
		}

		{ // Verified.
			for (n in 0 ... 0x100 - 1)
			{
				table2[0x100 + n] = new Node(false, 0, true, -1, -1, -1);
			}
			
			//std.file.write("table_out", cast(ubyte[])cast(void[])*(&table2[0..table2.length]));
		}

		var cnodes:Int = 0x100;
		var vinfo:Array<Int> = [0, 0];

		while (true)
		{
			for (m in 0 ... 2)
			{
				vinfo[m] = -1;

				// Find the node with min_value.
				var min_value:Int = 0x3FFFFFFF;
				
				for (n in 0 ... cnodes)
				{
					var cnode:Node = table2[n];

					if ((cnode.v0) && (cnode.v1 < min_value))
					{
						vinfo[m] = n;
						min_value = cnode.v1;
					}
				}

				if (vinfo[m] != -1)
				{
					var _node:Node = table2[vinfo[m]];
					
					_node.v0 = false;
					_node.v3 = cnodes;
				}
			}
			
			//assert(0 == 1);
			
			node = new Node();
			node.v0 = true;
			node.v1 = ((vinfo[1] != -1) ? table2[vinfo[1]].v1 : 0) + table2[vinfo[0]].v1;
			node.v2 = true;
			node.v3 =-1;
			node.v4 = vinfo[0];
			node.v5 = vinfo[1];

			//writefln("node(%03x): ", cnodes, node);
			table2[cnodes++] = node;
			
			if (node.v1 == sum_of_values) break;
		}
		
		trace("method2: " + (haxe.Timer.stamp() - start));
		
		return cnodes - 1;
	}

	/**
	 * 
	 * @param	src
	 * @param	dst
	 * @param	nodes
	 * @param	method2_res
	 */
	//#if cpp
	//@:functionCode("
	//	Float start = ::haxe::Timer_obj::stamp();
	//	{
	//		int mask = (int)0;
	//		int currentByte = (int)0;
	//		int iter = (int)0;
	//		int srcMax = src->length;
	//		Array< bool > v2List = Array_obj< bool >::__new();
	//		Array< int > v4List = Array_obj< int >::__new();
	//		Array< int > v5List = Array_obj< int >::__new();
	//		{
	//			int _g1 = (int)0;
	//			int _g = nodes->length;
	//			while(((_g1 < _g))){
	//				int n = (_g1)++;
	//				v2List->push(nodes->__get(n)->v2);
	//				v4List->push(nodes->__get(n)->v4);
	//				v5List->push(nodes->__get(n)->v5);
	//			}
	//		}
	//		bool * v2ListPtr = v2List->Pointer();
	//		int * v4ListPtr = v4List->Pointer();
	//		int * v5ListPtr = v5List->Pointer();
	//		unsigned char * srcPtr = src->b->Pointer();
	//		unsigned char * srcEnd = srcPtr + src->length;
	//		
	//		unsigned char * dstPtr = dst->b->Pointer();
	//		unsigned char * dstEnd = dstPtr + dst->length;
	//		{
	//			while (dstPtr < dstEnd){
	//				int cvalue = method2_res;
	//				while (v2ListPtr[cvalue]) {
	//					if (!mask) {
	//						if (srcPtr >= srcEnd) break;
	//						currentByte = *(srcPtr++);
	//						mask = 0x80;
	//					}
	//					cvalue = (currentByte & mask) ? v5ListPtr[cvalue] : v4ListPtr[cvalue];
	//					mask >>= 1;
	//				}
	//				*(dstPtr++) = (unsigned char)cvalue;
	//			}
	//		}
	//	}
	//	::haxe::Log_obj::trace((HX_CSTRING(\"huffman: \") + ((::haxe::Timer_obj::stamp() - start))),hx::SourceInfo(HX_CSTRING(\"CompressedBG.hx\"),291,HX_CSTRING(\"engines.ethornell.CompressedBG\"),HX_CSTRING(\"uncompress_huffman\")));
	//")
	//#end
	@:noStack static public function uncompress_huffman(src:ByteArray, dst:ByteArray, nodes:Array<Node>, method2_res:Int):Void
	{
		#if !cpp
		var start:Float = haxe.Timer.stamp();
		//Timer2.measure(function()
		{
			var mask:Int = 0;
			var currentByte:Int = 0;
			var iter:Int = 0;
			var srcn:Int = 0;
			var srcMax:Int = src.length;

			var v2List:Array<Bool> = [];
			var v4List:Array<Int> = [];
			var v5List:Array<Int> = [];
			for (n in 0 ... nodes.length) {
				v2List.push(nodes[n].v2);
				v4List.push(nodes[n].v4);
				v5List.push(nodes[n].v5);
			}
			
			Memory.select(dst);

			for (n in 0 ... dst.length)
			{
				var cvalue:Int = method2_res;
				
				#if cpp
				while (untyped v2List.__unsafe_get(cvalue))
				#else
				while (v2List[cvalue])
				#end
				{
					if (mask == 0)
					{
						if (srcn >= srcMax) break;

						#if cpp
							currentByte = untyped src.b.__unsafe_get(srcn++);
						#else
							currentByte = src[srcn++];
						#end
						//trace(currentByte);
						mask = 0x80;
					}
					
					#if cpp
						cvalue = untyped ((currentByte & mask) != 0) ? v5List.__unsafe_get(cvalue) : v4List.__unsafe_get(cvalue);
					#else
						cvalue = ((currentByte & mask) != 0) ? v5List[cvalue] : v4List[cvalue];
					#end
					mask >>>= 1;
				}

				Memory.setByte(n, cvalue);
				//dst[n] = cvalue;
			}
		}
		
		trace("huffman: " + (haxe.Timer.stamp() - start));
		//);
		#end
	}

	/**
	 * 
	 * @param	src
	 * @param	dst
	 */
	#if cpp
	@:functionCode("
		Float start = ::haxe::Timer_obj::stamp();
		{
			bool type = false;
			
			unsigned char * srcPtr = src->b->Pointer();
			unsigned char * srcEnd = srcPtr + src->b->length;

			unsigned char * dstPtr = dst->b->Pointer();
			unsigned char * dstEnd = dstPtr + dst->b->length;

			while (srcPtr < srcEnd) {
				int len;
				{
					int c;
					int v = 0;
					int shift = 0;
					
					do {
						c = *(srcPtr++);
						v |= (c & 0x7F) << shift;
						shift += 7;
					} while ((c & 0x80) != 0);
					
					len = v;
				}
				
				if (type) {
					memset(dstPtr, 0, len);
					dstPtr += len;
				}
				else {
					memcpy(dstPtr, srcPtr, len);
					dstPtr += len;
					srcPtr += len;
				}
				type = !(type);
			}
		}
		::haxe::Log_obj::trace((HX_CSTRING(\"rle: \") + ((::haxe::Timer_obj::stamp() - start))),hx::SourceInfo(HX_CSTRING(\"CompressedBG.hx\"),383,HX_CSTRING(\"engines.ethornell.CompressedBG\"),HX_CSTRING(\"uncompress_rle\")));
	")
	#end
	@:noStack static public function uncompress_rle(src:ByteArray, dst:ByteArray):Void
	{
		#if !cpp
		var start:Float = haxe.Timer.stamp();
		//Timer2.measure(function()
		{
			dst.position = 0;
			var type:Bool = false;
			
			Memory.select(dst);
			var dstPos:Int = 0;
			
			while (src.bytesAvailable > 0)
			{
				var len:Int = Utils.readVariable(src);
				
				// RLE (for byte 00).
				if (type)
				{
					while (len >= 4) { Memory.setI32(dstPos, 0); dstPos += 4; len -= 4; }
					while (len >= 1) { Memory.setByte(dstPos, 0); dstPos += 1; len -= 1; }
				}
				// Copy from stream.
				else
				{
					while (len >= 4) { Memory.setI32(dstPos, src.readUnsignedInt()); dstPos += 4; len -= 4; }
					while (len >= 1) { Memory.setByte(dstPos, src.readUnsignedByte()); dstPos += 1; len -= 1; }
				}
				
				type = !type;
			}
		}
		//);
		
		trace("rle: " + (haxe.Timer.stamp() - start));
		#end
	}

	/**
	 * 
	 * @param	output
	 * @param	data0
	 */
	public function unpack_real(data0:ByteArray):BitmapData
	{
		return switch (header.bpp) {
			case 24: unpack_real_24_32(data0, 24);
			case 32: unpack_real_24_32(data0, 32);
			//case 8: break; // Not implemented yet.
			default: throw(new Error('Unimplemented BPP ${header.bpp}'));
		};
	}

	@:noStack public inline function unpack_real_24_32(data0:ByteArray, bpp:Int = 32):BitmapData
	{
		var width:Int = header.w, height:Int = header.h;
		var start:Float = haxe.Timer.stamp();
		var bmp:BitmapData = new BitmapData(width, height);
		
		//Timer2.measure(function()
	
		// trace(header.w);
		// trace(header.h);
		// trace(bpp);
		// trace(data0.length);
		
		var data0Pos:Int = 0;
		
		data0.position = 0;
		
		var rowLen:Int = width * 4;
		
		var prevRow:ByteArray = ByteArrayUtils.newByteArrayWithLength(rowLen, Endian.LITTLE_ENDIAN);
		var currentRow:ByteArray = ByteArrayUtils.newByteArrayWithLength(rowLen, Endian.LITTLE_ENDIAN);
		var _tempRow:ByteArray;
		var pixels:ByteArray = ByteArrayUtils.newByteArrayWithLength(rowLen * height, Endian.LITTLE_ENDIAN);
		
		var accumR:Int = 0, accumG:Int = 0, accumB:Int = 0, accumA:Int = ((bpp == 32) ? 0 : 0xFF);
		var extractR:Int = 0, extractG:Int = 0, extractB:Int = 0, extractA:Int = 0;
		var extractUpR:Int = 0, extractUpG:Int = 0, extractUpB:Int = 0, extractUpA:Int = 0;
		
		bmp.lock();
		for (y in 0 ... height) {
			
			var currentN:Int = 0;
			
			for (x in 0 ... width) {
				#if cpp
				extractB = untyped (data0.b.__unsafe_get(data0Pos++) & 0xFF);
				extractG = untyped (data0.b.__unsafe_get(data0Pos++) & 0xFF);
				extractR = untyped (data0.b.__unsafe_get(data0Pos++) & 0xFF);
				if (bpp == 32) extractA = untyped (data0.b.__unsafe_get(data0Pos++) & 0xFF);
				#else
				extractB = (data0[data0Pos++] & 0xFF);
				extractG = (data0[data0Pos++] & 0xFF);
				extractR = (data0[data0Pos++] & 0xFF);
				if (bpp == 32) extractA = (data0[data0Pos++] & 0xFF);
				#end
				
				if (y == 0) {
					accumR = (accumR + extractR) & 0xFF;
					accumG = (accumG + extractG) & 0xFF;
					accumB = (accumB + extractB) & 0xFF;
					if (bpp == 32) accumA = (accumA + extractA) & 0xFF;
				} else {
					#if cpp
					if (bpp == 32) extractUpA = untyped prevRow.b.__unsafe_get(currentN + 0); // A
					extractUpR = untyped prevRow.b.__unsafe_get(currentN + 1); // R
					extractUpG = untyped prevRow.b.__unsafe_get(currentN + 2); // G
					extractUpB = untyped prevRow.b.__unsafe_get(currentN + 3); // B
					#else
					if (bpp == 32) extractUpA = prevRow[currentN + 0]; // A
					extractUpR = prevRow[currentN + 1]; // R
					extractUpG = prevRow[currentN + 2]; // G
					extractUpB = prevRow[currentN + 3]; // B
					#end
					
					if (x == 0) {
						//c = BmpColor.add(extract_up, extract);
						accumR = (extractUpR + extractR) & 0xFF;
						accumG = (extractUpG + extractG) & 0xFF;
						accumB = (extractUpB + extractB) & 0xFF;
						if (bpp == 32) accumA = (extractUpA + extractA) & 0xFF;
					} else {
						//c = BmpColor.add(BmpColor.avg(c, extract_up), extract);
						
						accumR = (((accumR + extractUpR) >> 1) + extractR) & 0xFF;
						accumG = (((accumG + extractUpG) >> 1) + extractG) & 0xFF;
						accumB = (((accumB + extractUpB) >> 1) + extractB) & 0xFF;
						if (bpp == 32) accumA = (((accumA + extractUpA) >> 1) + extractA) & 0xFF;
					}
				}
				
				//accumA = 0xFF;
				//accumR = 0xFF;
				
				#if cpp
				untyped currentRow.b.__unsafe_set(currentN + 0, (bpp == 32) ? accumA : 0xFF); // A
				untyped currentRow.b.__unsafe_set(currentN + 1, accumR); // R
				untyped currentRow.b.__unsafe_set(currentN + 2, accumG); // G
				untyped currentRow.b.__unsafe_set(currentN + 3, accumB); // B
				#else
				currentRow[currentN + 0] = (bpp == 32) ? accumA : 0xFF; // A
				currentRow[currentN + 1] = accumR; // R
				currentRow[currentN + 2] = accumG; // G
				currentRow[currentN + 3] = accumB; // B
				#end
				
				currentN += 4;
			}

			currentRow.position = 0;
			bmp.setPixels(new Rectangle(0, y, width, 1), currentRow);

			_tempRow = prevRow;
			prevRow = currentRow;
			currentRow = _tempRow;
		}
		bmp.unlock();
		
		trace("unpack_real_24_32: " + (haxe.Timer.stamp() - start));
		return bmp;
	}
}

// Header for the CompressedBG.
class Header
{
	public var magic:String;
	public var w:Int;
	public var h:Int;
	public var bpp:Int;
	public var _pad0:Int;
	public var _pad1:Int;
	public var data1_len:Int;
	public var data0_val:Int;
	public var data0_len:Int;
	public var hash0:Int;
	public var hash1:Int;
	public var _unknown0:Int;
	public var _pad2:Int;
	
	public function new() {
		
	}
	
	public function readFrom(ba:ByteArray)
	{
		
		magic = ba.readMultiByte(0x10, "iso-8859-1");
		if (magic != ("CompressedBG___" + String.fromCharCode(0))) throw(new Error("Invalid CompressedBG"));

		w = ba.readUnsignedShort();
		h = ba.readUnsignedShort();
		bpp = ba.readUnsignedInt();
		_pad0 = ba.readUnsignedInt();
		_pad1 = ba.readUnsignedInt();
		data1_len = ba.readUnsignedInt();
		data0_val = ba.readUnsignedInt();
		data0_len = ba.readUnsignedInt();
		hash0 = ba.readUnsignedByte();
		hash1 = ba.readUnsignedByte();
		_unknown0 = ba.readUnsignedByte();
		_pad2 = ba.readUnsignedByte();
	}
}

/**
 * Node for the Huffman decompression.
 */
class Node
{
	/**
	 * 
	 */
	public var v0:Bool;
	
	/**
	 * Value?
	 */
	public var v1:Int;
	
	/**
	 * Is leaf
	 */
	public var v2:Bool;
	
	/**
	 * Number of nodes/levels? Something like that.
	 */
	public var v3:Int;
	
	/**
	 * Left index
	 */
	public var v4:Int;
	
	/**
	 * Right index.
	 */
	public var v5:Int;
	
	//public var vv:Array<Int>;
	public function new(v0:Bool = false, v1:Int = 0, v2:Bool = false, v3:Int = 0, v4:Int = 0, v5:Int = 0)
	{
		this.v0 = v0;
		this.v1 = v1;
		this.v2 = v2;
		this.v3 = v3;
		this.v4 = v4;
		this.v5 = v5;
	}
	
	public function toString():String { return '($v0, $v1, $v2, $v3, $v4, $v5)'; }
}