package reflash.gl.wgl;
import haxe.Log;
import haxe.PosInfos;
import openfl.gl.GL;
class WGLCommon
{
	 static public function check(?posInfos:PosInfos):Void
	{
		//Log.trace('GL:! ${posInfos.fileName}:${posInfos.className}:${posInfos.methodName}:${posInfos.lineNumber}}');
		var error = GL.getError();
		if (error != GL.NO_ERROR)
		{
			Log.trace('GL: Error! $error: ${getErrorString(error)} ${posInfos.fileName}:${posInfos.className}:${posInfos.methodName}:${posInfos.lineNumber}}');
		}
	}

	static public function getErrorString(error:Int):String
	{
		return switch(error)
		{
			case GL.NO_ERROR: "NO_ERROR";
			case GL.INVALID_ENUM: "INVALID_ENUM";
			case GL.INVALID_VALUE: "INVALID_VALUE";
			case GL.INVALID_OPERATION: "INVALID_OPERATION";
			case GL.OUT_OF_MEMORY: "OUT_OF_MEMORY";
			default: 'UNKNOWN_$error';
		}
	}
}
