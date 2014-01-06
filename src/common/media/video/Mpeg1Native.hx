package common.media.video;

@:cppFileCode('
#include "../../../../../../../../extra/mpeg.cpp"
')
class Mpeg1Native
{
	public function new()
	{

	}

	public function play()
	{
		_play();
	}

	@:functionCode('load_and_play_file();')
	private function _play()
	{

	}
}
