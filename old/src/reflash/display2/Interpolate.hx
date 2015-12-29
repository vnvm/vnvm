package reflash.display2;

class Interpolate {
    static public function interpolate(a:Dynamic, b:Dynamic, ratio:Float):Dynamic {
        return a * ratio + b * (1 - ratio);
    }
}
