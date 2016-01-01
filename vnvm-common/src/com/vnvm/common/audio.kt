package com.vnvm.common

import com.vnvm.common.view.Views
import com.vnvm.graphics.Music
import com.vnvm.graphics.Sound

data class SoundTransform(val vol: Double, val panning: Double)

class SoundChannel(val views: Views) {
	private var last: Sound? = null

	fun Sound.stop():Unit = views.audio.stop(this)

	fun play(sound: Sound): Unit {
		last?.stop()
		last = sound
		views.audio.play(sound)
	}

	fun stop() {
		last?.stop()
	}
}

class MusicChannel(val views: Views) {
	private var last: Music? = null

	fun Music.stop():Unit = views.audio.stop(this)

	fun play(music: Music): Unit {
		last?.stop()
		last = music
		views.audio.play(music)
	}

	fun stop() {
		last?.stop()
	}
}