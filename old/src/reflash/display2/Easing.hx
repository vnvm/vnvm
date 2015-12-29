package reflash.display2;

class Easing {
    static public function linear(step:Float):Float {
        return step;
    }

    static public function easeInOutQuad(step:Float):Float {
        var t = step, b = 0, c = 1, d = 1;
        return ((t /= d / 2) < 1) ? (c / 2 * t * t + b) : (-c / 2 * ((t - 1) * ((t - 1) - 2) - 1) + b);
    }
}
