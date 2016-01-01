package com.vnvm.common

import com.vnvm.common.view.Views
import com.vnvm.graphics.Music
import com.vnvm.graphics.Sound

data class SoundTransform(val vol: Double, val panning: Double)

class SoundChannel(val views: Views) {
	private var last: Sound? = null

	fun play(sound: Sound): Unit {
		if (last != null) views.audio.stop(last!!)
		last = sound
		views.audio.play(sound)
	}

	fun stop() {
	}
}

class MusicChannel(val views: Views) {
	private var last: Music? = null

	fun play(music: Music): Unit {
		if (last != null) views.audio.stop(last!!)
		last = music
		views.audio.play(music)
	}

	fun stop() {
	}
}