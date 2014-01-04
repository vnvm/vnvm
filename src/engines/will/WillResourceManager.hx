package engines.will;

import engines.will.formats.wip.WIP;
import vfs.Stream;
import flash.utils.ByteArray;
import promhx.Promise;
import flash.errors.Error;
import engines.will.formats.arc.ARC;
import vfs.VirtualFileSystem;

class WillResourceManager
{
	private var arcList:Array<ARC>;

	public function new()
	{
		arcList = new Array<ARC>();
	}

	static public function createFromFileSystemAsync(vfs:VirtualFileSystem)
	{
		return new WillResourceManager().loadAsync(vfs);
	}

	private function loadAsync(vfs:VirtualFileSystem)
	{
		var arcNameList = [
			"Bgm.arc", "Chip.arc",
			"CARDIMG.arc",
			"rio.arc", "Se.arc", "Voice.arc",
			"Chip_0.arc", "Chip_1.arc", "Chip_2.arc", "Chip_3.arc", "Chip_4.arc", "Chip_5.arc",
			"Chip_6.arc", "Chip_A.arc", "Chip_B.arc", "Chip_C.arc", "Chip_D.arc", "Chip_E.arc",
			"Chip_F.arc", "Chip_G.arc", "Chip_H.arc", "Chip_I.arc", "Chip_J.arc", "Chip_K.arc",
			"Chip_L.arc", "Chip_M.arc", "Chip_N.arc", "Chip_O.arc", "Chip_P.arc", "Chip_Q.arc",
			"Chip_R.arc", "Chip_S.arc", "Chip_T.arc", "Chip_U.arc", "Chip_V.arc", "Chip_W.arc",
			"Chip_X.arc", "Chip_Y.arc", "Chip_Z.arc"
			//null
		];

		var promise = new Promise<WillResourceManager>();
		var _this = this;

		function nextStep()
		{
			if (arcNameList.length == 0) {
				promise.resolve(_this);
				return;
			}
			var arcName = arcNameList.pop();
			vfs.openAsync('$arcName').then(function(stream:Stream)
			{
				ARC.fromStreamAsync(stream).then(function(arc:ARC)
				{
					arcList.push(arc);
					nextStep();
				});
			});
		}

		nextStep();

		return promise;
	}

	public function readAllBytesAsync(name:String):Promise<ByteArray>
	{
		for (arc in arcList)
		{
			if (arc.contains(name))
			{
				return arc.openAndReadAllAsync(name);
			}
		}
		return Promise.promise(null);
		//throw(new Error('Can\'t find "$name"'));
	}

	public function getWipWithMaskAsync(name:String):Promise<WIP>
	{
		var promise = new Promise<WIP>();

		getWipAsync('$name.WIP').then(function(colorWip:WIP)
		{
			if (colorWip == null) throw('Can\'t find $name.WIP');
			getWipAsync('$name.MSK').then(function(alphaWip:WIP)
			{
				colorWip.mergeAlpha(alphaWip);
				promise.resolve(colorWip);
			});
		});
		return promise;
	}

	public function getWipAsync(name:String):Promise<WIP>
	{
		return readAllBytesAsync(name).then(function(data:ByteArray):WIP
		{
			return (data != null) ? WIP.fromByteArray(data) : null;
		});
	}
}
