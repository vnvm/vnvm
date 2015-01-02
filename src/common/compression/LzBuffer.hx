package common.compression;

import haxe.io.BytesData;
import haxe.io.Bytes;
import flash.utils.ByteArray;

class LzBuffer {
    private var input:Bytes;
    private var inputData:BytesData;
    private var inputPos:Int;
    private var inputLength:Int;

    private var output:ByteArray;
    private var outputData:Bytes;
    private var outputPos:Int;

    private var ring:RingBuffer;

    public function new(input:ByteArray, output:ByteArray, ring:RingBuffer) {
        this.inputPos = input.position;
        this.inputLength = input.length;
        this.input = ByteArrayUtils.ByteArrayToBytes(input);
        this.inputData = this.input.getData();
        this.output = output;
        this.outputData = Bytes.ofData(this.output.getData());
        this.outputPos = 0;
        this.ring = ring;
    }

#if cpp
    @:functionCode("return this->inputData->__unsafe_get(((this->inputPos)++));")
#end
    @:noStack public function readByte():Int {
        return Bytes.fastGet(inputData, inputPos++);
    }

    @:noStack public inline function hasAtLeast(bytes:Int):Bool {
        return (inputLength - inputPos) >= bytes;
    }

    @:noStack public function copyBytesFromRingBuffer(position:Int, count:Int):Void {
        ring.setReadPosition(position);
        while (count-- > 0) this.writeByte(ring.readByte());
    }

#if cpp

    @:functionCode("
		this->ring->writeByte(byte);
		this->outputData->__unsafe_set((this->outputPos)++, byte);
		return null();
	") #end
    @:noStack public function writeByte(byte:Int):Void {
        ring.writeByte(byte);
        //this.outputData.writeByte(byte);
        outputData.set(outputPos++, cast byte);
//output[outputPos++] = byte;
    }
}
