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

    public function addTimer(time:Milliseconds, callback: Void -> Void) {
        var elapsed:Int = 0;
        var updater:ViewComponent = null;
        updater = addUpdater(function(context:Update) {
            elapsed += Std.int(context.dt * 1000);
            if (elapsed >= time.toInt()) {
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

    public function animateAsync(time:Milliseconds, step: Float -> Void, ?easing:Float -> Float) {
        if (easing == null) easing = Easing.linear;

        var deferred = Promise.createDeferred();
        var elapsed:Int = 0;
        var updater:ViewComponent = null;
        updater = addUpdater(function(context:Update) {
            elapsed += context.dtMs;
            var ratio = Math.min(Math.max(elapsed / time.toInt(), 0), 1);
            step(easing(ratio));
            if (ratio >= 1) {
                updater.remove();
                deferred.resolve(null);
            }
        });
        return deferred.promise;
    }

    public function interpolateAsync(object:Dynamic, time:Milliseconds, target:Dynamic, ?easing:Float -> Float, ?step: Float -> Void):IPromise<Dynamic> {
        if (easing == null) easing = Easing.linear;
        var keys = Reflect.fields(target);
        var source = {};
        for (key in keys) Reflect.setField(source, key, Reflect.getProperty(object, key));

        return animateAsync(time, function(ratio:Float) {
            ratio = easing(ratio);
            for (key in keys) {
                Reflect.setField(object, key, Interpolate.interpolate(Reflect.field(source, key), Reflect.field(target, key), ratio));
            }
            if (step != null) step(ratio);
        });
    }

    public function waitAsync(time:Milliseconds):IPromise<Dynamic> {
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
