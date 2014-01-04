package reflash.gl.wgl;

import haxe.Log;
import openfl.gl.GL;

typedef ComponentInfo =
{
	index: Int,
	count: Int,
	glType: Int,
	offset: Int,
	normalized: Bool
}

class WGLVertexDescriptor implements IGLVertexDescriptor
{
	private var program:IGLProgram;
	private var array:Array<ComponentInfo>;
	private var totalSize:Int;

	public function new(program:IGLProgram)
	{
		this.program = program;
		this.array = [];
		this.totalSize = 0;
	}

	static public function create(program:IGLProgram):WGLVertexDescriptor
	{
		return new WGLVertexDescriptor(program);
	}

	public function addField(name:String, count:Int, normalized:Bool = false)
	{
		var type:WGLType = WGLType.FLOAT;
		var attribute = program.getAttribute(name);

		var typeSize = switch (type) {
			case WGLType.BYTE | WGLType.UNSIGNED_BYTE: 1;
			case WGLType.SHORT | WGLType.UNSIGNED_SHORT: 2;
			case WGLType.FLOAT: 4;
		};

		var glType = switch (type) {
			case WGLType.BYTE: GL.BYTE;
			case WGLType.UNSIGNED_BYTE: GL.UNSIGNED_BYTE;
			case WGLType.SHORT: GL.SHORT;
			case WGLType.UNSIGNED_SHORT: GL.UNSIGNED_SHORT;
			case WGLType.FLOAT: GL.FLOAT;
		};

		var elementSize = count * typeSize;

		this.array.push(
		{
			index: attribute.index,
			count: count,
			glType: glType,
			offset: this.totalSize,
			normalized: normalized
		});

		this.totalSize += elementSize;
	}

	public function use()
	{
		for (item in array)
		{
			GL.enableVertexAttribArray(item.index);
			WGLCommon.check();
			//Log.trace('${item.index}, ${item.count}, ${item.glType}, ${item.normalized}, ${this.totalSize}, ${item.offset}');
			GL.vertexAttribPointer(item.index, item.count, item.glType, item.normalized, this.totalSize, item.offset);
			WGLCommon.check();
			//GL.vertexAttribPointer(item.index, 4, item.glType, item.normalized, 0, item.offset);
		}
	}

	public function unuse()
	{
		for (item in array)
		{
			GL.disableVertexAttribArray(item.index);
			WGLCommon.check();
		}
	}
}
