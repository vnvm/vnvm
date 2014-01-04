package reflash.gl.wgl;

import reflash.gl.wgl.WGLProgram;

class WGLAttribute implements IGLAttribute
{
	private var program:WGLProgram;
	public var index(default, null):Int;

	public function new(program:WGLProgram, index:Int)
	{
		this.program = program;
		this.index = index;
	}
}