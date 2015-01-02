package common;

class ArrayUtils {
    static public function array1D<T>(a:Int, value:T):Array<T> {
        return [for (n in 0 ... a) value];
    }

    static public function array2D<T>(a:Int, b:Int, value:T):Array<Array<T>> {
        return [for (n in 0 ... a) array1D(b, value)];
    }

    static public function array2D_2<T>(a:Int, b:Int, valueType:T, value:T):Array<Array<T>> {
        return [for (n in 0 ... a) array1D(b, value)];
    }

    static public function array3D<T>(a:Int, b:Int, c:Int, value:T):Array<Array<Array<T>>> {
        return [for (n in 0 ... a) array2D(b, c, value)];
    }
}
