package vfs;
import lang.promise.IPromise;
import flash.utils.ByteArray;

class StreamBase {
    public var position:Int;
    public var length:Int;

    public function readBytesAsync(length:Int):IPromise<ByteArray> {
        throw('Not implemented Stream.readBytesAsync : $this');
        return null;
    }
}