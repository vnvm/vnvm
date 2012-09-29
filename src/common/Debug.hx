package common;
import haxe.PosInfos;
import nme.errors.Error;

/**
 * ...
 * @author soywiz
 */

class Debug { 
     #if debug 
     static public var assertProc : Bool -> String -> PosInfos -> Bool = defaultAssertProc; 
     static public function assert( cond : Bool, ?msg : String, ?pos : PosInfos ) : Bool 
         return assertProc(cond, msg, pos) 
     private static function defaultAssertProc(cond, msg, pos):Bool { 
     	if (cond) return true; 
		throw(new Error("Assert failed : " + msg + " : " + pos));
     }
    #else 
     static public inline function assert( cond : Bool, ?msg : String, ?pos : PosInfos ) : Bool return true 
    #end 
} 
