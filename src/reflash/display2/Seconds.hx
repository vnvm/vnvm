package reflash.display2;

abstract Seconds(Float) {
    public function new(v:Float) this = v;

    public function toFloat():Float return this;
    @:from static public function fromMilliseconds(ms:Milliseconds) return new Seconds(ms.toInt() / 1000);
    @:to public function toMilliseconds() return new Milliseconds(Std.int(this * 1000));
}
