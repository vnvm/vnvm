package reflash.gl;

import lang.IDisposable;

interface IGLProgram extends IDisposable
{
	function use():Void;
	function getAttribute(name:String):IGLAttribute;
	function getVertexDescriptor():IGLVertexDescriptor;
	function getUniform(name:String):IGLUniform;
}
