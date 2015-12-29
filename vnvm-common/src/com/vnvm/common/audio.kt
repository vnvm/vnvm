package com.vnvm.common

data class SoundTransform(val vol: Double, val panning: Double)

class Sound {
	fun loadCompressedDataFromByteArray(byteArray: ByteArray, length: Int) {
	}

}

class SoundChannel {
	fun play(sound: Sound): Unit {

	}

	fun stop() {
	}
}