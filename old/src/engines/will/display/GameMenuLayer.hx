package engines.will.display;

import engines.will.formats.anm.ANM;
import engines.will.formats.wip.WIP;
import engines.will.formats.anm.TBL;
import flash.display.BitmapData;
import reflash.display.Sprite2;

class GameMenuLayer extends Sprite2 {
    private var wipLayer:WIPLayer;

    public function new() {
        super();
    }

    private function updateMenuEnable() {
        if (wipLayer == null) return;

        for (n in 0 ... tbl.count) {
            var enableFlag = tbl.enable_flags[n];
//var enable = gameState.getFlag(enableFlag) != 0;
//Log.trace('INDEX:$n: FLAG:$enableFlag: $enable');
            wipLayer.setLayerEnabled(n + 1, true);
        }
    }

    private var tbl:TBL;
    private var tblMask:BitmapData;

    public function setTableMask(tbl:TBL, tblMask:BitmapData) {
        this.tbl = tbl;
        this.tblMask = tblMask;
        updateMenuEnable();
    }

    public function setAnmAndWip(anm:ANM, wip:WIP) {
        this.removeChildren();
        this.wipLayer = null;
        if (wip != null) {
            this.addChild(this.wipLayer = new WIPLayer(wip));
        }
    }

    public function getTableAt(x:Int, y:Int):Int {
        if (tblMask != null) {
            if (x < 0 || y < 0 || x >= tblMask.width || y >= tblMask.height) return 0;
            return tblMask.getPixel(x, y) & 0xFF;
        }
        return 0;
    }

    public function getWipLayer():WIPLayer {
        return this.wipLayer;
    }
}
