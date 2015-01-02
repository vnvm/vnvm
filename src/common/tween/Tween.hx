package common.tween;

import lang.promise.Deferred;
import lang.promise.IPromise;
import lang.MathEx;
import common.event.EventListenerGroup;
import lang.ObjectUtils;
import lang.signal.Signal;
import flash.events.Event;
import haxe.Timer;

class Tween {
    private var totalTime:Float;
    private var stepSignal:Signal<Float>;
    private var easing:Float -> Float;

    private function new(totalTime:Float) {
        this.totalTime = totalTime;
        this.stepSignal = new Signal<Float>();
        this.easing = Easing.linear;
    }

    static public function forTime(time:Float):Tween {
        return new Tween(time);
    }

    public function onStep(handler:Float -> Void):Tween {
        this.stepSignal.add(handler);
        return this;
    }

    public function interpolateTo(object:Dynamic, dstProperties:Dynamic, easing:Float -> Float = null):Tween {
        if (easing == null) easing = Easing.linear;

        var propertyList = Reflect.fields(dstProperties);
        var srcProperties = ObjectUtils.extractFields(object, propertyList);

        onStep(function(step:Float) {
            step = easing(step);
            for (property in propertyList) {
                var src = Reflect.field(srcProperties, property);
                var dst = Reflect.field(dstProperties, property);
                var interpolated = MathEx.interpolate(step, src, dst);
//Log.trace('$src, $dst -> $interpolated');
                Reflect.setField(object, property, interpolated);
            }
        });

        return this;
    }

    public function withEasing(easing:Float -> Float):Tween {
        this.easing = easing;
        return this;
    }

    public function animateAsync():IPromise<Dynamic> {
        var deferred = new Deferred<Dynamic>();
        var start = Timer.stamp();
        var stageGroup = new EventListenerGroup(StageReference.stage);

        function stepRatio(ratio:Float) {
            stepSignal.dispatch(easing(ratio));

            if (ratio >= 1) {
                stageGroup.dispose();
                deferred.resolve(null);
            }
        }

        function step(?e) {
            var current = Timer.stamp();
            var elapsed = current - start;
            var ratio = (totalTime > 0) ? MathEx.clamp(elapsed / totalTime, 0, 1) : 1;
            stepRatio(ratio);
        }

        stageGroup.addEventListener(Event.ENTER_FRAME, step);

        deferred.onCancel.add(function(e) {
            stepRatio(1);
        });

        step();

        return deferred.promise;
    }
}