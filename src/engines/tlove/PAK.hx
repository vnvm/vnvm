package engines.tlove;

import lang.promise.IPromise;
import common.ByteArrayUtils;
import vfs.SliceStream;
import vfs.Stream;
import flash.errors.Error;
import flash.utils.ByteArray;

class PAK {
    var items:Map<String, SliceStream>;

    private function new() {
        this.items = new Map<String, SliceStream>();
    }

    public function getBytesAsync(name:String):IPromise<ByteArray> {
        var stream:Stream = get(name);
        return stream.readAllBytesAsync();
    }

    public function get(name:String):Stream {
        var item:SliceStream = items.get(name.toUpperCase());
        if (item == null) throw(new Error('Can\'t find \'$name\''));
        return SliceStream.fromAll(item);
    }

    public function getNames():Array<String> {
        var a = [];
        for (item in items.keys()) a.push(item);
        return a;
    }

    static public function newPakAsync(pakStream:Stream):IPromise<PAK> {
        var pak:PAK = new PAK();
        var countByteArray:ByteArray;
        var headerByteArray:ByteArray;

        return pakStream.readBytesAsync(2).pipe(function(countByteArray:ByteArray) {
            var headerSize:Int = countByteArray.readUnsignedShort();

            return pakStream.readBytesAsync(headerSize).then(function(headerByteArray:ByteArray) {
                var names:Array<String> = [];
                var offsets:Array<Int> = [];

                while (headerByteArray.position < headerByteArray.length) {
                    var name:String = ByteArrayUtils.readStringz(headerByteArray, 0xC);
                    var offset:Int = headerByteArray.readUnsignedInt();
                    names.push(name.toUpperCase());
                    offsets.push(offset);
                }

                for (n in 0 ... names.length - 1) {
                    pak.items.set(names[n], SliceStream.fromBounds(pakStream, offsets[n], offsets[n + 1]));
                }

                return pak;
            });
        });
    }
}