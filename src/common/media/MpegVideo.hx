package common.media;

import lang.promise.Promise;
import lang.promise.Deferred;
import common.event.EventListenerGroup;
import lang.promise.IPromise;
import flash.events.Event;
import flash.display.Bitmap;
import common.media.video.Mpeg1Native;
import common.media.audio.MP2Native;
import common.media.audio.AudioStreamSound;
import common.media.container.MpegPs;
import haxe.io.Input;
import flash.display.Sprite;

class MpegVideo extends Sprite
{
	public function new()
	{
		super();
	}

	private var mpeg:MpegPs;
	private var videoStream:Input;
	private var audioStream:Input;

	public function loadAndPlayAsync(stream:Input):IPromise<Dynamic>
	{
		var deferred = Promise.createDeferred();

		this.mpeg = new MpegPs(stream);
		this.videoStream = mpeg.getVideoStream(0);
		this.audioStream = mpeg.getAudioStream(0);

		new AudioStreamSound(MP2Native.createWithStream(audioStream)).play();

		var mpegVideo = new Mpeg1Native();
		mpegVideo.open(videoStream);

		var eventListenerGroup = new EventListenerGroup(this);

		eventListenerGroup.addEventListener(Event.ENTER_FRAME, function(?e)
		{
			if (!mpegVideo.decodeFrame())
			{
				eventListenerGroup.dispose();
				deferred.resolve(null);
			}
		});

		if (numChildren > 0) removeChildren();
		addChild(new Bitmap(mpegVideo.imageBitmapData));

		return deferred.promise;
	}
}
