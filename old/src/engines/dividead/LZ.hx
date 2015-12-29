package engines.dividead;
import haxe.io.BytesData;
import reflash.Bytes3;
import common.ByteArrayUtils;
import haxe.Timer;
import common.compression.IPositionCountExtractor;
import common.compression.LzOptions;
import common.compression.LzDecoder;
import haxe.io.Bytes;
import flash.utils.ByteArray;

class LZ {
    static public function is(data:ByteArray):Bool {
        data.position = 0;
        var magic:String = data.readUTFBytes(2);
        return magic == 'LZ';
    }

    static public function decode(data:ByteArray):ByteArray {
        data.position = 0;
        var magic:String = data.readUTFBytes(2);
        var compressedSize:Int = data.readInt();
        var uncompressedSize:Int = data.readInt();

        if (magic != "LZ") throw("Invalid LZ stream");

        return _decode(data, uncompressedSize);
    }

    static private function _decode(input:ByteArray, uncompressedSize:Int):ByteArray {
//return _decodeFast(input, uncompressedSize);

        var uncompressed:ByteArray;
        Timer.measure(function() {
            //uncompressed = _decodeGeneric(input, uncompressedSize);
            uncompressed = _decodeFast(input, uncompressedSize);
        });
        return uncompressed;
    }

    static private function _decodeGeneric(input:ByteArray, uncompressedSize:Int):ByteArray {
        var options = new LzOptions();

        options.ringBufferSize = 0x1000;
        options.startRingBufferPos = 0xFEE;
//options.setCountPositionBits(4, 12);
        options.compressedBit = 0;
        options.countPositionBytesHighFirst = false;
        options.positionCountExtractor = new DivideadPositionCountExtractor();

        return LzDecoder.decode(input, options, uncompressedSize);
    }

    @:noStack static private function _decodeFast(input:ByteArray, uncompressedSize:Int):ByteArray {
        var inputData = ByteArrayUtils.ByteArrayToBytes(input);
        var i = inputData.getData();
        var inputPosition = input.position;
        var inputLength:Int = input.length;

        var outputData = Bytes.alloc(uncompressedSize + 0x1000);
        var o = outputData.getData();
        var outputPosition = 0x1000;
        var ringStart = 0xFEE;
        //var extractor = new DivideadPositionCountExtractor();

        //var bd = Bytes.alloc(1000).getData();
        //var ptr = Pointer.fromArray(bd, 0);

        //var ptr:cpp.Pointer<cpp.UInt8> = null;
        //var ptr:cpp.Pointer<haxe.io.Unsigned_char__> = null;
        //trace(ptr); // some pointer address

        //Memory.select(input);

        //Log.trace("[1]");
        while (inputPosition < inputLength) {
            var code:Int = fastGet(i, inputPosition++) | 0x100;

            while (code != 1) {
                //Log.trace("[3]");

                // Uncompressed
                if ((code & 1) != 0) {
                    fastSet(o, outputPosition++, fastGet(i, inputPosition++));
                }
                // Compressed
                else {
                    if (inputPosition >= inputLength) break;

                    var paramL:Int = fastGet(i, inputPosition++);
                    var paramH:Int = fastGet(i, inputPosition++);

                    var param:Int = paramL | (paramH << 8);

                    var ringOffset:Int = extractPosition(param);
                    var ringLength:Int = extractCount(param);

                    //Log.trace('Compressed: $param, $ringOffset, $ringLength');

                    var convertedP:Int = ((ringStart + outputPosition) & 0xFFF) - ringOffset;
                    if (convertedP < 0) convertedP = convertedP + 0x1000;

                    var outputReadOffset:Int = outputPosition - convertedP;

                    while (ringLength-- > 0) {
                        fastSet(o, outputPosition++, fastGet(o, outputReadOffset++));
                    }
                }

                code >>= 1;
            }
        }

        return ByteArrayUtils.BytesToByteArray(outputData.sub(0x1000, uncompressedSize));
    }

    @:noStack static private inline function fastSet(b:BytesData, pos : Int, v : Int ) : Void {
        #if neko
		untyped __dollar__sset(b,pos,v);
		#elseif flash9
		b[pos] = v;
		#elseif php
		b[pos] = untyped __call__("chr", v);
		#elseif cpp
		untyped b.__unsafe_set(pos, v);
		#elseif java
		b[pos] = cast v;
		#elseif cs
		b[pos] = cast v;
		#else
        b[pos] = v & 0xFF;
        #end
    }


    @:noStack static private inline function fastGet( b : BytesData, pos : Int ) : Int {
#if neko
		return untyped __dollar__sget(b,pos);
		#elseif flash9
		return b[pos];
		#elseif php
		return untyped __call__("ord", b[pos]);
		#elseif cpp
		return untyped b.__unsafe_get(pos);
		#elseif java
		return untyped b[pos] & 0xFF;
		#else
        return b[pos];
#end
    }

    @:noStack static private inline function extractPosition(param:Int):Int {
        return (param & 0xFF) | ((param >> 4) & 0xF00);
    }

    @:noStack static private inline function extractCount(param:Int):Int {
        return ((param >> 8) & 0xF) + 3;
    }
}

class DivideadPositionCountExtractor implements IPositionCountExtractor {
    @:noStack public inline function extractPosition(param:Int):Int {
        return (param & 0xFF) | ((param >> 4) & 0xF00);
    }

    @:noStack public inline function extractCount(param:Int):Int {
        return ((param >> 8) & 0xF) + 3;
    }

    public function new() {

    }
}
