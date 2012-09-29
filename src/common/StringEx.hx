package common;
import nme.errors.Error;

/**
 * ...
 * @author 
 */

class StringEx 
{
	static inline var parts:String = "0123456789ABCDEF";

	static public function parseInt(stringValue:String, radix:Int):Int {
		if (stringValue.substr(0, 1) == '-') return - parseInt(stringValue.substr(1), radix);
		
		var value:Int = 0;
		
		for (n in 0 ... stringValue.length) {
			var charCode:Int = stringValue.charCodeAt(n);
			
			value *= radix;
			
			if (charCode >= '0'.charCodeAt(0) && charCode <= '9'.charCodeAt(0)) {
				value += (charCode - '0'.charCodeAt(0)) + 0;
			} else if (charCode >= 'a'.charCodeAt(0) && charCode <= 'z'.charCodeAt(0)) {
				value += (charCode - 'a'.charCodeAt(0)) + 10;
			} else if (charCode >= 'A'.charCodeAt(0) && charCode <= 'Z'.charCodeAt(0)) {
				value += (charCode - 'A'.charCodeAt(0)) + 10;
			}
		}
		
		return value;
	}

	static public function intToString(value:Int, radix:Int):String {
		if (value < 0) return "-" + intToString(-value, radix);
		if (value == 0) return "0";

		var out:String = "";
		while (value != 0) {
			var digit:Int = Std.int(value % radix);
			out = parts.charAt(digit) + out;
			value = Std.int(value / radix);
		}

		return out;
	}

	static public function sprintf(format:String, params: Array<Dynamic>):String {
		var reg:EReg = ~/%(-)?(0)?(\d*)(d|x|X|s)/g;
		var f:EReg;
		
		return reg.customReplace(format, function (f:EReg):String {
			var minus:String = f.matched(1);
			var zero:String = f.matched(2);
			var numbers:String = f.matched(3);
			var type:String = f.matched(4);
			var direction:Int = 1;
			var padChar:String = ' ';
			var padCount:Int = Std.parseInt(numbers);
			var out:String = "";
			if (minus != null) direction = -1;
			if (zero != null) padChar = zero;
			out = switch (type) {
				case 'b': intToString(params.shift(), 2);
				case 'd': intToString(params.shift(), 10);
				case 'x': intToString(params.shift(), 16).toLowerCase();
				case 'X': intToString(params.shift(), 16).toUpperCase();
				case 's': params.shift();
				default: throw(new Error(Std.format("Format '%$type'")));
			};
			if (direction > 0) {
				out = StringTools.lpad(out, padChar, padCount);
			} else {
				out = StringTools.rpad(out, padChar, padCount);
			}
			//BraveLog.trace(Std.format("$minus, $zero, $numbers, $format"));
			return out;
		});
	}

}