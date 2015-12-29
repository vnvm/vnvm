package lang;

class ObjectUtils {
    static public function extractFields(input:Dynamic, fields:Array<String>):Dynamic {
        var output = {};
        for (property in fields) {
            Reflect.setField(output, property, Reflect.field(input, property));
        }
        return output;
    }
}
