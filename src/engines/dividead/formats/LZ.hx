package engines.dividead.formats;
import reflash.Bytes3;
import common.ByteArrayUtils;
import haxe.Timer;
import common.compression.IPositionCountExtractor;
import common.compression.LzOptions;
import common.compression.LzDecoder;
import haxe.io.Bytes;
import flash.utils.ByteArray;

class LZ {
    static public function decode(data:ByteArray):ByteArray {
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
            uncompressed = _decodeGeneric(input, uncompressedSize);
//uncompressed = _decodeFast(input, uncompressedSize);
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
        var inputBytes = ByteArrayUtils.ByteArrayToBytes(input);
        var inputData:Bytes3 = Bytes.ofData(inputBytes.getData());
        var inputPosition = input.position;
        var inputLength:Int = input.length;

        //Memory.getByte

        var outputBytes = Bytes.alloc(uncompressedSize);
        var outputData:Bytes3 = Bytes.ofData(outputBytes.getData());
        var outputPosition = 0;
        var ringStart = 0xFEE;
        //var extractor = new DivideadPositionCountExtractor();

        //Memory.select(input);

        //Log.trace("[1]");
        while (inputPosition < inputLength) {
            var code:Int = (cast inputData[inputPosition++]) | 0x100;

            while (code != 1) {
                //Log.trace("[3]");

                // Uncompressed
                if ((code & 1) != 0) {
                    outputData[outputPosition++] = inputData[inputPosition++];
                }
                // Compressed
                else {
                    if (inputPosition >= inputLength) break;

                    var paramL:Int = cast inputData[inputPosition++];
                    var paramH:Int = cast inputData[inputPosition++];

                    var param:Int = paramL | (paramH << 8);

                    var ringOffset:Int = extractPosition(param);
                    var ringLength:Int = extractCount(param);

                    //Log.trace('Compressed: $param, $ringOffset, $ringLength');

                    var convertedP:Int = ((ringStart + outputPosition) & 0xFFF) - ringOffset;
                    if (convertedP < 0) convertedP += 0x1000;

                    var outputReadOffset:Int = outputPosition - convertedP;

                    while (outputReadOffset < 0) {
                        outputData[outputPosition++] = cast 0;
                        //outputBytes.set(outputPosition++, 0);
                        outputReadOffset++;
                        ringLength--;
                    }

                    while (ringLength-- > 0) {
                        //outputBytes.set(outputPosition++, Bytes.fastGet(outputData, outputReadOffset++));
                        //outputData[outputPosition++] = Bytes.fastGet(outputData, outputReadOffset++);
                        outputData[outputPosition++] = outputData[outputReadOffset++];
                    }
                }

                code >>= 1;
            }
        }

        return ByteArrayUtils.BytesToByteArray(outputBytes);
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