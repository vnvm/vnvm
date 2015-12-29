package engines.dividead;
import sys.io.File;
import flash.utils.ByteArray;
import common.assets.AssetsFileSystemCpp;
import vfs.Stream;
import vfs.LocalFileSystem;
import vfs.VirtualFileSystem;
class DivideadCommandLine {
    public function new() {
    }

    static public function extractDl1(file:String) {
        var fs:LocalFileSystem = new LocalFileSystem(".");

        var assetsPath = new AssetsFileSystemCpp().getAssetsLocalPath();

        fs.openAsync('$assetsPath/dividead/SG.DL1').pipe(function(s:Stream) {
            return DL1.loadAsync(s);
        }).then(function(dl1:DL1) {
            for (file in dl1.listFiles()) {
                trace(file);
                dl1.openAndReadAllAsync(file).then(function(data:ByteArray) {
                    if (LZ.is(data)) data = LZ.decode(data);
                    sys.io.File.write("/tmp/" + file).write(data);
                });
            }
        });
    }

    static public function main() {
        DivideadCommandLine.extractDl1('test');
    }
}
