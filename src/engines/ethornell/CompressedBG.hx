package engines.ethornell;
import common.ByteArrayUtils;
import common.imaging.BmpColor;
import common.LangUtils;
import common.Reference;
import common.StringEx;
import nme.display.BitmapData;
import nme.errors.Error;
import nme.utils.ByteArray;
import nme.utils.Endian;
import nme.utils.Timer;

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
	public function new(s:ByteArray)
	{
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
	}

	/**
	 * 
	 * @param	data
	 * @param	hash_val
	 */
	static public function decode_chunk0(data:ByteArray, hash_val:Int):Void
	{
		var hash_val_ref:Reference<Int> = new Reference<Int>(hash_val);
		
		for (n in 0 ... data.length)
		{
			var prev:Int = data[n];
			var next:Int = (data[n] - (Utils.hash_update(hash_val_ref) & 0xFF)) & 0xFF;
			data[n] = next;
			//trace(StringEx.sprintf("%02X -> %02X", [prev, next]));
		}
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
		var sum_of_values:Int = 0;
		var node:Node;
		
		{ // Verified.
			for (n in 0 ... 0x100)
			{
				var node:Node = table2[n];
				node.v0 = (table1[n] > 0) ? 1 : 0;
				node.v1 = table1[n];
				node.v2 = 0;
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
			for (n in 0 ... 0x100 - 1) {
				table2[0x100 + n] = new Node(0, 0, 1, -1, -1, -1);
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

					if ((cnode.v0 != 0) && (cnode.v1 < min_value))
					{
						vinfo[m] = n;
						min_value = cnode.v1;
					}
				}

				if (vinfo[m] != -1)
				{
					var _node:Node = table2[vinfo[m]];
					
					_node.v0 = 0;
					_node.v3 = cnodes;
				}
			}
			
			//assert(0 == 1);
			
			node = new Node();
			node.v0 = 1;
			//node.v1 = ((vinfo[1] != 0xFFFFFFFF) ? table2[vinfo[1]].v1 : 0) + table2[vinfo[0]].v1;
			node.v1 = ((vinfo[1] != -1) ? table2[vinfo[1]].v1 : 0) + table2[vinfo[0]].v1;
			node.v2 = 1;
			node.v3 =-1;
			node.v4 = vinfo[0];
			node.v5 = vinfo[1];

			//writefln("node(%03x): ", cnodes, node);
			table2[cnodes++] = node;
			
			if (node.v1 == sum_of_values) break;
		}
		
		return cnodes - 1;
	}

	/**
	 * 
	 * @param	src
	 * @param	dst
	 * @param	nodes
	 * @param	method2_res
	 */
	static public function uncompress_huffman(src:ByteArray, dst:ByteArray, nodes:Array<Node>, method2_res:Int):Void
	{
		var mask:Int = 0x80;
		var currentByte:Int = src.readUnsignedByte();
		var iter:Int = 0;
		
		
		var start:Float = haxe.Timer.stamp();
		for (n in 0 ... dst.length)
		{
			var cvalue:Int = method2_res;

			if (nodes[method2_res].v2 == 1)
			{
				do
				{
					var bit:Bool = ((currentByte & mask) != 0);
					mask >>= 1;

					cvalue = bit ? nodes[cvalue].v5 : nodes[cvalue].v4;

					if (mask == 0)
					{
						if (src.bytesAvailable == 0) {
							break;
						}
						currentByte = src.readUnsignedByte();
						//trace(currentByte);
						mask = 0x80;
					}
				}
				while (nodes[cvalue].v2 == 1);
			}

			dst[n] = cvalue;
		}
		var end:Float = haxe.Timer.stamp();
		trace(end - start);
	}

	/**
	 * 
	 * @param	src
	 * @param	dst
	 */
	static public function uncompress_rle(src:ByteArray, dst:ByteArray):Void
	{
		dst.position = 0;
		var type:Bool = false;

		while (src.bytesAvailable > 0)
		{
			var len:Int = Utils.readVariable(src);
			
			// RLE (for byte 00).
			if (type)
			{
				for (n in 0 ... len) dst.writeByte(0);
			}
			// Copy from stream.
			else
			{
				for (n in 0 ... len) dst.writeByte(src.readByte());
			}
			
			type = !type;
		}
	}

	/**
	 * 
	 * @param	output
	 * @param	data0
	 */
	public function unpack_real(data0:ByteArray):BitmapData
	{
		return switch (header.bpp) {
			case 24, 32: unpack_real_24_32(data0, header.bpp);
			//case 8: break; // Not implemented yet.
			default: throw(new Error(Std.format("Unimplemented BPP ${header.bpp}")));
		};
	}

	public function unpack_real_24_32(data0:ByteArray, bpp:Int = 32):BitmapData
	{
		var bmp:BitmapData = new BitmapData(header.w, header.h);
		var c:BmpColor = new BmpColor(0, 0, 0, ((bpp == 32) ? 0 : 0xFF));
		trace(header.w);
		trace(header.h);
		trace(bpp);
		trace(data0.length);
		
		data0.position = 0;
		for (y in 0 ... header.h) {
			for (x in 0 ... header.w) {
				var extract:BmpColor = new BmpColor(0, 0, 0, 0);
				extract.r = data0.readUnsignedByte();
				extract.g = data0.readUnsignedByte();
				extract.b = data0.readUnsignedByte();
				
				if (bpp == 32) {
					extract.a = data0.readUnsignedByte();
				} else {
					extract.a = 0xFF;
				}
				
				if (y == 0) {
					c = BmpColor.add(c, extract);
				} else {
					var extract_up:BmpColor = BmpColor.fromV(bmp.getPixel(x, y - 1));
					if (x == 0) {
						c = BmpColor.add(extract_up, extract);
					} else {
						c = BmpColor.add(BmpColor.avg(c, extract_up), extract);
					}
				}
				
				bmp.setPixel(x, y, c.getV());
			}
		}
		return bmp;
		/*
		auto out_ptr = output.ptr;
		Color c = Color(0, 0, 0, (bpp == 32) ? 0 : 0xFF);
		ubyte* src = data0.ptr;
		uint*  dst = output.ptr;
		
		Color extract_32() { scope (exit) src += 4; return Color(src[0], src[1], src[2], src[3]); }
		Color extract_24() { scope (exit) src += 3; return Color(src[0], src[1], src[2], 0); }
		
		auto extract = (bpp == 32) ? &extract_32 : &extract_24;
		Color extract_up() { return Color(*(dst - header.w)); }

		for (int x = 0; x < header.w; x++) {
			*dst++ = (c += extract()).v;
		}
		for (int y = 1; y < header.h; y++) {
			*dst++ = (c = (extract_up + extract())).v;
			for (int x = 1; x < header.w; x++) {
				*dst++ = (c = (Color.avg([c, extract_up]) + extract())).v;
			}
		}
		*/
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

// Node for the Huffman decompression.
class Node
{
	public var v0:Int;
	public var v1:Int;
	public var v2:Int;
	public var v3:Int;
	public var v4:Int;
	public var v5:Int;
	
	//public var vv:Array<Int>;
	public function new(v0:Int = 0, v1:Int = 0, v2:Int = 0, v3:Int = 0, v4:Int = 0, v5:Int = 0)
	{
		this.v0 = v0;
		this.v1 = v1;
		this.v2 = v2;
		this.v3 = v3;
		this.v4 = v4;
		this.v5 = v5;
	}
	
	public function toString():String { return StringEx.sprintf("(%d, %d, %d, %d, %d, %d)", [v0, v1, v2, v3, v4, v5]); }
}