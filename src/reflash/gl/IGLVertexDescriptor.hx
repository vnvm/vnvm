package reflash.gl;

interface IGLVertexDescriptor
{
	function addField(name:String, count:Int, normalized:Bool = false):Void;
	function use():Void;
	function unuse():Void;
}
