package reflash;

import haxe.io.Bytes;

abstract Bytes3(Bytes) to Bytes from Bytes {
    public function new(s:Bytes) this = s;
    public var length(get, never):Int;
    private inline function get_length():Int return this.length;
    @:arrayAccess inline function get(k:Int) return this.get(k);
    @:arrayAccess inline function set(k:Int, v:Int) {
        this.set(k, v);
        //return this.get(k);
    }
}