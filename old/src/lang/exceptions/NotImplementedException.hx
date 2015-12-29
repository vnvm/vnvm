package lang.exceptions;

import haxe.PosInfos;
import flash.errors.Error;

class NotImplementedException extends Error
{
	public function new(message:String = "Not implemented exception", ?posInfos:PosInfos)
	{
		super(posInfos.fileName + '@' + posInfos.lineNumber + ': ' + message + ' (' + posInfos.className + '.' + posInfos.methodName + ')');
	}
}