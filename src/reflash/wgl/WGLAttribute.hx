package reflash.wgl;

import reflash.wgl.WGLProgram;

class WGLAttribute
{
	private var program:WGLProgram;
	public var index:Int;

	public function new(program:WGLProgram, index:Int)
	{
		this.program = program;
		this.index = index;
	}
}