package reflash.display2;
abstract Milliseconds(Int) {
    public function new(v:Int) this = v;

    public function toInt():Int return this;
    @:from static public function fromSeconds(s:Seconds) return new Milliseconds(Std.int(s.toFloat() * 1000));
    @:to public function toSeconds() return new Seconds(this / 1000);
}
