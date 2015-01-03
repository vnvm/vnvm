package reflash.display2;
import lang.promise.IPromise;
import lang.promise.Promise;
import haxe.Timer;
import flash.display.Sprite;

class View extends Sprite implements Updatable {
    public function new() {
        super();
    }

    public var components = new Array<Updatable>();

    public function addTimer(time:Int, callback: Void -> Void) {
        var elapsed:Int = 0;
        var updater:ViewComponent = null;
        updater = addUpdater(function(context:Update) {
            elapsed += Std.int(context.dt * 1000);
            if (elapsed >= time) {
                updater.remove();
                callback();
            }
        });
    }

    public function addUpdater(callback: Update -> Void):UpdateComponent {
        var result = new UpdateComponent(this, callback);
        components.push(result);
        return result;
    }

    public function animateAsync(time:Int, step: Float -> Void) {
        var deferred = Promise.createDeferred();
        var elapsed:Int = 0;
        var updater:ViewComponent = null;
        updater = addUpdater(function(context:Update) {
            elapsed += context.dtMs;
            var ratio = Math.min(Math.max(elapsed / time, 0), 1);
            step(ratio);
            if (ratio >= 1) {
                updater.remove();
                deferred.resolve(null);
            }
        });
        return deferred.promise;
    }

    public function interpolateAsync(object:Dynamic, time:Int, target:Dynamic, ?easing:Float -> Float, ?step: Float -> Void):IPromise<Dynamic> {
        var keys = Reflect.fields(target);
        var source = {};
        for (key in keys) Reflect.setField(source, key, Reflect.getProperty(object, key));
        if (easing == null) easing = Easing.linear;

        return animateAsync(time, function(ratio:Float) {
            ratio = easing(ratio);
            for (key in keys) {
                Reflect.setField(object, key, Interpolate.interpolate(Reflect.field(source, key), Reflect.field(target, key), ratio));
            }
            if (step != null) step(ratio);
        });
    }

    public function waitAsync(time:Int):IPromise<Dynamic> {
        var deferred = Promise.createDeferred();
        addTimer(time, function() {
            deferred.resolve(null);
        });
        return deferred.promise;
    }

    public function update(context:Update):Void {
        for (component in components.slice(0)) component.update(context);
    }
}

class UpdateComponent extends ViewComponent {
    private var cb: Update -> Void;

    public function new(view:View, cb: Update -> Void) {
        super(view);
        this.cb = cb;
    }

    override public function update(context:Update):Void {
        if (cb != null) cb(context);
    }
}
